import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/snackbar_model.dart';
import 'package:mini_reddit_v2/core/services/cash.dart' as cache_service;
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_community_posts_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_saved_posts_provider.dart';

final savePostProvider =
    StateNotifierProvider.family<SavePostNotifier, bool, String>(
  (ref, postId) =>
      SavePostNotifier(repo: PostRepoImpl(PostDataSource()), ref: ref),
);

class SavePostNotifier extends StateNotifier<bool> {
  final PostRepo repo;
  final Ref ref;

  SavePostNotifier({required this.repo, required this.ref}) : super(false);

  void savePost(String postId) async {
    try {
      final result = await repo.savePost(postId);
      result.fold(
        (failure) {
          ref.read(savePostSnackBarProvider.notifier).state = SnackBarModel(
            message: failure.message,
            isError: true,
          );
          debugPrint('error in save post result: ${failure.message}');
        },
        (success) async {
          updateLocalState(true, postId);
          _updateAllContexts(postId, true);
          await _invalidateSavedPostsCache();
        },
      );
    } catch (e) {
      ref.read(savePostSnackBarProvider.notifier).state = SnackBarModel(
        message: e.toString(),
        isError: true,
      );
      debugPrint('exception in save post: $e');
    }
  }

  void _updateAllContexts(String postId, bool isSaved) {
    // 1. Update FeedProvider
    final feedNotifier = ref.read(feedProvider.notifier);
    final feedPost =
        ref.read(feedProvider).feed?.where((p) => p.id == postId).firstOrNull;
    if (feedPost != null) {
      feedNotifier.updateFeedPostLocally(feedPost.copyWith(isSaved: isSaved));
    }

    // 2. Update Community Posts
    final communityPostsNotifier =
        ref.read(fetchCommunityPostsProvider.notifier);
    final communityPost = ref
        .read(fetchCommunityPostsProvider)
        .value
        ?.where((p) => p.id == postId)
        .firstOrNull;
    if (communityPost != null) {
      communityPostsNotifier
          .updatePostLocally(communityPost.copyWith(isSaved: isSaved));
    }

    // 3. Update Post Details if open
    final postDetails = ref.read(postProvider).post;
    if (postDetails != null && postDetails.id == postId) {
      // Assuming PostProvider has a way to update its state locally or we just refresh it
      ref.read(postProvider.notifier).getPostDetails(postId: postId);
    }
  }

  void unsavePost(String postId) async {
    try {
      final result = await repo.unsavePost(postId);
      result.fold(
        (failure) {
          ref.read(savePostSnackBarProvider.notifier).state = SnackBarModel(
            message: failure.message,
            isError: true,
          );
          debugPrint('error in unsave post result: ${failure.message}');
        },
        (success) async {
          updateLocalState(false, postId);
          _updateAllContexts(postId, false);
          await _invalidateSavedPostsCache();
        },
      );
    } catch (e) {
      ref.read(savePostSnackBarProvider.notifier).state = SnackBarModel(
        message: e.toString(),
        isError: true,
      );
      debugPrint('exception in unsave post: $e');
    }
  }

  void updateLocalState(bool isSaved, String postId) {
    state = isSaved;
  }

  Future<void> _invalidateSavedPostsCache() async {
    // Clear the Hive cache for saved posts
    final cashService = cache_service.CashService();
    await cashService.delete(cache_service.Key.userSavedPost);

    // Also re-fetch the saved posts provider
    await ref
        .read(userSavedPostsProvider.notifier)
        .fetchSavedPosts(forceRefresh: true);
  }
}

final savePostSnackBarProvider = StateProvider<SnackBarModel?>((ref) {
  return null;
});
