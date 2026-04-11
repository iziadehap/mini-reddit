import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_repo_impl.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final fetchCommunityPostsProvider =
    StateNotifierProvider<
      FetchCommunityPostsNotifier,
      AsyncValue<List<FeedPostModel>>
    >((ref) {
      return FetchCommunityPostsNotifier(
        ref: ref,
        communitiesRepo: CommunitiesRepoImpl(
          communitiesDataSource: CommunitiesDataSource(),
        ),
        postRepo: PostRepoImpl(PostDataSource()),
      );
    });

class FetchCommunityPostsNotifier
    extends StateNotifier<AsyncValue<List<FeedPostModel>>> {
  final Ref ref;
  final CommunitiesRepo communitiesRepo;
  final PostRepo postRepo;

  FetchCommunityPostsNotifier({
    required this.ref,
    required this.communitiesRepo,
    required this.postRepo,
  }) : super(const AsyncValue.loading());

  Future<void> fetchCommunityPosts(String communityId) async {
    state = const AsyncValue.loading();
    final result = await communitiesRepo.getCommunityPosts(
      communityId: communityId,
    );
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (posts) => state = AsyncValue.data(posts),
    );
  }

  void removePostLocally(String postId) {
    final posts = state.value;
    if (posts == null) return;
    final updated = posts.where((p) => p.id != postId).toList();
    if (updated.length != posts.length) {
      state = AsyncValue.data(updated);
    }
  }

  void updatePostLocally(FeedPostModel updatedPost) {
    final posts = state.value;
    if (posts == null) return;
    
    bool hasChanges = false;
    final updated = posts.map((p) {
      if (p.id == updatedPost.id) {
        hasChanges = true;
        return updatedPost;
      }
      return p;
    }).toList();
    
    if (hasChanges) {
      state = AsyncValue.data(updated);
    }
  }

  Future<void> votePost({
    required String postId,
    required int value,
    required String authorId,
  }) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;
    if (authorId == currentUserId) return;

    final posts = state.value;
    if (posts == null) return;

    // Save for rollback
    final originalPosts = posts;

    // Optimistic Update
    final updatedPosts = posts.map((post) {
      if (post.id == postId) {
        return post.toggleVote(value);
      }
      return post;
    }).toList();

    state = AsyncValue.data(updatedPosts);

    // Network request
    final result = await postRepo.votePost(
      userId: currentUserId,
      postId: postId,
      value: value,
    );

    result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(originalPosts);
      },
      (success) {
        // Sync with server score if available
        if (success.data != null && success.data!['new_score'] != null) {
          final newScore = success.data!['new_score'] as int;
          final newValue = success.data!['value'] as int;

          final syncedPosts = state.value!.map((post) {
            if (post.id == postId) {
              return post.copyWith(
                score: newScore,
                userVote: newValue == 0 ? null : newValue,
                clearUserVote: newValue == 0,
              );
            }
            return post;
          }).toList();
          state = AsyncValue.data(syncedPosts);
        }
      },
    );
  }
}
