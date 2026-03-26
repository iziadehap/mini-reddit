import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_repo_impl.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';

final fetchCommunitiesProvider =
    StateNotifierProvider<
      CommunitiesNotifier,
      AsyncValue<List<CommunityModel>>
    >((ref) {
      return CommunitiesNotifier(
        ref: ref,
        communitiesRepo: CommunitiesRepoImpl(CommunitiesDataSource()),
      );
    });

class CommunitiesNotifier
    extends StateNotifier<AsyncValue<List<CommunityModel>>> {
  final Ref ref;
  final CommunitiesRepo communitiesRepo;

  CommunitiesNotifier({required this.ref, required this.communitiesRepo})
    : super(const AsyncValue.loading());

  //! ==========================
  // !! Communities section
  //! ==========================

  Future<void> fetchCommunities({String? search}) async {
    setLoading();
    final data = await communitiesRepo.getCommunities(search: search);
    data.fold(
      (failure) => setError(failure.message),
      (communities) => setData(communities),
    );
  }

  // Future<void> joinCommunity(String communityId) async {
  //   final data = await communitiesRepo.joinCommunity(communityId);
  //   data.fold((failure) => setError(failure.message), (_) {
  //     ref.read(userCommunitiesProvider.notifier).clearCache();
  //     fetchCommunities();
  //   });
  // }
  //
  // Future<void> leaveCommunity(String communityId) async {
  //   final data = await communitiesRepo.leaveCommunity(communityId);
  //   data.fold((failure) => setError(failure.message), (_) {
  //     ref.read(userCommunitiesProvider.notifier).clearCache();
  //     fetchCommunities();
  //   });
  // }
  //
  // Future<Map<String, dynamic>?> createCommunity({
  //   required String name,
  //   String? description,
  //   String? imageUrl,
  //   String? bannerUrl,
  // }) async {
  //   final data = await communitiesRepo.createCommunity(
  //     name: name,
  //     description: description,
  //     imageUrl: imageUrl,
  //     bannerUrl: bannerUrl,
  //   );
  //   return data.fold(
  //     (failure) {
  //       setError(failure.message);
  //       return {'success': false, 'message': failure.message};
  //     },
  //     (successResult) {
  //       ref.read(userCommunitiesProvider.notifier).clearCache();
  //       fetchCommunities();
  //       return successResult;
  //     },
  //   );
  // }
  //
  // Future<List<String>> uploadPostImage(List<File> imageFiles) async {
  //   final result = await postRepo.uploadPostImage(imageFiles);
  //   return result.fold((failure) {
  //     state = state.copyWith(error: failure.message);
  //     return [];
  //   }, (urls) => urls);
  // }
  //
  // Future<String?> uploadCommunityImage(File file) async {
  //   final result = await communitiesRepo.uploadCommunityImage(file);
  //   return result.fold((failure) {
  //     state = AsyncValue.error(failure.message, StackTrace.current);
  //     return null;
  //   }, (url) => url);
  // }
  //
  // Future<void> createCommunityPost({
  //   required String communityId,
  //   required String title,
  //   required String content,
  //   String? flairId,
  //   List<String>? imageUrls,
  // }) async {
  //   String postType = 'text';
  //   if (imageUrls != null && imageUrls.isNotEmpty) {
  //     postType = 'image';
  //   }
  //   state = state.copyWith(isLoading: true, error: null);
  //   final result = await communitiesRepo.createPostInCommunity(
  //     communityId: communityId,
  //     title: title,
  //     content: content,
  //     imageUrls: imageUrls,
  //     postType: postType,
  //     flairId: flairId,
  //   );
  //
  //   result.fold(
  //     (failure) =>
  //         state = state.copyWith(isLoading: false, error: failure.message),
  //     (newPost) {
  //       state = state.copyWith(
  //         feed: [newPost, ...?state.feed],
  //         isLoading: false,
  //       );
  //     },
  //   );
  // }
  //
  // Future<void> sharePostToCommunity({
  //   required String originalPostId,
  //   required String targetCommunityId,
  //   String? additionalContent,
  // }) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   final result = await communitiesRepo.addPostToCommunity(
  //     originalPostId: originalPostId,
  //     targetCommunityId: targetCommunityId,
  //     additionalContent: additionalContent,
  //   );
  //
  //   result.fold(
  //     (failure) =>
  //         state = state.copyWith(isLoading: false, error: failure.message),
  //     (newPost) {
  //       state = state.copyWith(
  //         feed: [newPost, ...?state.feed],
  //         isLoading: false,
  //       );
  //     },
  //   );
  // }
  //
  // Future<void> removeCommunityPost(String postId) async {
  //   // Optimistic Update
  //   final originalFeed = state.feed;
  //   if (state.feed != null) {
  //     state = state.copyWith(
  //       feed: state.feed!.where((post) => post.id != postId).toList(),
  //     );
  //   }
  //
  //   final result = await communitiesRepo.removePostFromCommunity(postId);
  //
  //   result.fold(
  //     (failure) =>
  //         state = state.copyWith(feed: originalFeed, error: failure.message),
  //     (_) => null, // Stay with optimistic update
  //   );
  // }

  // Future<void> fetchCommunityPosts(String communityId) async {
  //   setLoading();
  //   final result = await communitiesRepo.getCommunityPosts(
  //     communityId: communityId,
  //   );

  //   result.fold(
  //     (failure) => setError(failure.message),
  //     (feed) => setData(feed),
  //     // state = state.copyWith(
  //     //   feed: feed,
  //     //   isLoading: false,
  //     //   isFirstLoad: false,
  //     //   isEnd: feed.length < 20,
  //     // ),
  //   );
  // }

  void clearCache() {
    state = const AsyncValue.loading();
    fetchCommunities();
  }

  // ---------------

  void setLoading() {
    state = AsyncValue.loading();
  }

  void setError(String error) {
    state = AsyncValue.error(error, StackTrace.current);
  }

  void setData(List<CommunityModel> communities) {
    state = AsyncValue.data(communities);
  }
}
