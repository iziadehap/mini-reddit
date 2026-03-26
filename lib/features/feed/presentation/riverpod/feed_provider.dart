import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/failure_model.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fatch_communities_provider.dart';
import 'package:mini_reddit_v2/features/feed/data/DataSource/feed_data_source.dart';
import 'package:mini_reddit_v2/features/feed/data/feed_repo_impl.dart';
import 'package:mini_reddit_v2/features/feed/domain/feed_repo.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_state.dart';
import 'package:mini_reddit_v2/core/riverpod/snackBar_provider.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final notifier = FeedNotifier(
    ref: ref,
    feedRepo: FeedRepoImpl(FeedDataSource(), CommunitiesDataSource()),
    postRepo: PostRepoImpl(PostDataSource()),
  );
  return notifier;
});

final communityFeedProvider =
    StateNotifierProvider.family<FeedNotifier, FeedState, String>((
      ref,
      communityName,
    ) {
      final notifier = FeedNotifier(
        ref: ref,
        feedRepo: FeedRepoImpl(FeedDataSource(), CommunitiesDataSource()),
        postRepo: PostRepoImpl(PostDataSource()),
      );
      // Initialize with the specific community
      Future.microtask(() {
        notifier.selectCommunity(communityName);
      });
      return notifier;
    });

class FeedNotifier extends StateNotifier<FeedState> {
  final Ref ref;
  final FeedRepo feedRepo;
  final PostRepo postRepo;

  FeedNotifier({
    required this.ref,
    required this.feedRepo,
    required this.postRepo,
  }) : super(FeedState.initial());

  String? get currentUserId {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  void updatePostLocally(PostDetailsModel updatedPost) {
    if (state.feed == null) return;

    bool hasChanges = false;
    final updatedFeed = state.feed!.map((post) {
      if (post.id == updatedPost.id) {
        if (post.score != updatedPost.score ||
            post.userVote != updatedPost.userVote ||
            post.commentsCount != updatedPost.commentsCount) {
          hasChanges = true;
          return post.copyWith(
            score: updatedPost.score,
            userVote: updatedPost.userVote,
            clearUserVote: updatedPost.userVote == null,
            commentsCount: updatedPost.commentsCount,
          );
        }
      }
      return post;
    }).toList();

    if (hasChanges) {
      state = state.copyWith(feed: updatedFeed);
    }
  }

  Future<void> votePost({
    required String postId,
    required int value,
    required String authorId,
  }) async {
    if (state.feed == null) return;

    if (authorId == currentUserId) {
      ref.read(snackBarProvider.notifier).state =
          'You cannot vote on your own post';
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // Save for rollback
    final originalFeed = state.feed;

    // Optimistic Update
    final updatedFeed = state.feed!.map((post) {
      if (post.id == postId) {
        return post.toggleVote(value);
      }
      return post;
    }).toList();

    state = state.copyWith(feed: updatedFeed);

    // Network request
    final result = await postRepo.votePost(
      userId: userId,
      postId: postId,
      value: value,
    );

    result.fold(
      (failure) {
        // Revert on failure
        state = state.copyWith(feed: originalFeed, error: failure.message);
      },
      (success) {
        // ✅ Sync with server score if available
        if (success.data != null && success.data!['new_score'] != null) {
          final newScore = success.data!['new_score'] as int;
          final newValue = success.data!['value'] as int;

          final updatedFeed = state.feed!.map((post) {
            if (post.id == postId) {
              return post.copyWith(
                score: newScore,
                userVote: newValue == 0 ? null : newValue,
                clearUserVote: newValue == 0,
              );
            }
            return post;
          }).toList();
          state = state.copyWith(feed: updatedFeed);
        }
      },
    );
  }

  Future<void> firstFetchFeed() async {
    state = state.copyWith(
      isLoading: true,
      isFirstLoad: true,
      error: null,
      isEnd: false,
    );

    final result = await _fetchFeedData(offset: 0);

    result.fold(
      (failure) {
        print("failure.message ${failure.message}");
        state = state.copyWith(
          isLoading: false,
          isFirstLoad: false,
          error: failure.message,
        );
      },
      (feed) {
        debugPrint("feed 0 ${feed[0].toJson()}");
        debugPrint("feed 1 ${feed[1].toJson()}");
        state = state.copyWith(
          feed: feed,
          isLoading: false,
          isFirstLoad: false,
          isEnd: feed.length < 10,
          error: null,
        );
      },
    );
  }

  Future<void> loadMoreFeed() async {
    if (state.feed == null || state.feed!.isEmpty) return;
    if (state.isLoadMore || state.isLoading || state.isEnd) return;

    state = state.copyWith(isLoadMore: true, error: null);

    final currentOffset = state.feed!.length;
    final result = await _fetchFeedData(offset: currentOffset);

    result.fold(
      (failure) {
        state = state.copyWith(isLoadMore: false, error: failure.message);
      },
      (newFeed) {
        state = state.copyWith(
          feed: [...state.feed!, ...newFeed],
          isLoadMore: false,
          isEnd: newFeed.length < 10,
          error: null,
        );
      },
    );
  }

  Future<Either<Failure, List<FeedPostModel>>> _fetchFeedData({
    required int offset,
  }) async {
    final List<String>? communityNames = state.selectedCommunityName != null
        ? [state.selectedCommunityName!]
        : null;

    switch (state.feedType) {
      case FeedType.hot:
        return await feedRepo.getHotFeed(
          offset: offset,
          limit: 10,
          communityNames: communityNames,
        );
      case FeedType.newFeed:
        return await feedRepo.getNewFeed(
          offset: offset,
          limit: 10,
          communityNames: communityNames,
        );
      case FeedType.top:
        return await feedRepo.getTopFeed(
          timeframe: state.timeframe,
          offset: offset,
          limit: 10,
          communityNames: communityNames,
        );
      case FeedType.best:
        return await feedRepo.getBestFeed(offset: offset, limit: 10);
      case FeedType.popular:
        return await feedRepo.getPopularFeed(offset: offset, limit: 10);
      case FeedType.user:
        if (state.targetUserId == null) {
          return Left(Failure('Target user ID is missing'));
        }
        return await feedRepo.getUserPosts(
          targetUserId: state.targetUserId!,
          offset: offset,
          limit: 10,
        );
      case FeedType.community:
        if (state.selectedCommunityName == null) {
          return Left(Failure('Community name is missing'));
        }
        return await feedRepo.getCommunityFeed(
          communityName: state.selectedCommunityName!,
          offset: offset,
          limit: 10,
        );
      case FeedType.search:
        if (state.searchQuery == null || state.searchQuery!.isEmpty) {
          return Left(Failure('Search query is empty'));
        }
        return await feedRepo.searchPosts(
          query: state.searchQuery!,
          offset: offset,
          limit: 10,
          communityNames: communityNames,
        );
    }
  }

  void setFeedType(FeedType feedType) {
    if (state.feedType == feedType) return;
    state = state.copyWith(
      clearSelectedCommunityName: true,
      feedType: feedType,
      feed: [],
      isEnd: false,
      error: null,
    );
    firstFetchFeed();
  }

  void setTimeframe(TopFeedTimeframe timeframe) {
    if (state.timeframe == timeframe) return;
    state = state.copyWith(
      timeframe: timeframe,
      feed: [],
      isEnd: false,
      error: null,
    );
    if (state.feedType == FeedType.top) {
      firstFetchFeed();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      feedType: FeedType.search,
      feed: [],
      isEnd: false,
      error: null,
    );
    firstFetchFeed();
  }

  void setTargetUser(String userId) {
    state = state.copyWith(
      targetUserId: userId,
      feedType: FeedType.user,
      feed: [],
      isEnd: false,
      error: null,
    );
    firstFetchFeed();
  }

  void selectCommunity(String? communityName) {
    if (state.selectedCommunityName == communityName) return;
    state = state.copyWith(
      selectedCommunityName: communityName,
      feedType: communityName != null ? FeedType.community : FeedType.hot,
      feed: [],
      isEnd: false,
      error: null,
    );
    firstFetchFeed();
    if (communityName != null) {
      ref
          .read(fetchCommunitiesProvider.notifier)
          .fetchCommunities(search: communityName);
    }
  }

  // //! ==========================
  // // !! Communities section
  // //! ==========================

  // Future<void> fetchCommunities({String? search}) async {
  //   state = state.copyWith(isCommunitiesLoading: true, communitiesError: null);
  //   final data = await feedRepo.getCommunities(search: search);
  //   data.fold(
  //     (failure) => state = state.copyWith(
  //       isCommunitiesLoading: false,
  //       communitiesError: failure.message,
  //     ),
  //     (communities) => state = state.copyWith(
  //       communities: communities,
  //       isCommunitiesLoading: false,
  //     ),
  //   );
  // }

  // Future<void> joinCommunity(String communityId) async {
  //   final data = await feedRepo.joinCommunity(communityId);
  //   data.fold(
  //     (failure) => state = state.copyWith(communitiesError: failure.message),
  //     (_) {
  //       ref.read(userCommunitiesProvider.notifier).clearCache();
  //       fetchCommunities();
  //     },
  //   );
  // }

  // Future<void> leaveCommunity(String communityId) async {
  //   final data = await feedRepo.leaveCommunity(communityId);
  //   data.fold(
  //     (failure) => state = state.copyWith(communitiesError: failure.message),
  //     (_) {
  //       ref.read(userCommunitiesProvider.notifier).clearCache();
  //       fetchCommunities();
  //     },
  //   );
  // }

  // Future<Map<String, dynamic>?> createCommunity({
  //   required String name,
  //   String? description,
  //   String? imageUrl,
  //   String? bannerUrl,
  // }) async {
  //   final data = await feedRepo.createCommunity(
  //     name: name,
  //     description: description,
  //     imageUrl: imageUrl,
  //     bannerUrl: bannerUrl,
  //   );
  //   return data.fold(
  //     (failure) {
  //       state = state.copyWith(communitiesError: failure.message);
  //       return {'success': false, 'message': failure.message};
  //     },
  //     (successResult) {
  //       ref.read(userCommunitiesProvider.notifier).clearCache();
  //       fetchCommunities();
  //       return successResult;
  //     },
  //   );
  // }

  // Future<List<String>> uploadPostImage(List<File> imageFiles) async {
  //   final result = await postRepo.uploadPostImage(imageFiles);
  //   return result.fold((failure) {
  //     state = state.copyWith(error: failure.message);
  //     return [];
  //   }, (urls) => urls);
  // }

  // Future<String?> uploadCommunityImage(File file) async {
  //   final result = await feedRepo.uploadCommunityImage(file);
  //   return result.fold((failure) {
  //     state = state.copyWith(communitiesError: failure.message);
  //     return null;
  //   }, (url) => url);
  // }

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
  //   final result = await feedRepo.createPostInCommunity(
  //     communityId: communityId,
  //     title: title,
  //     content: content,
  //     imageUrls: imageUrls,
  //     postType: postType,
  //     flairId: flairId,
  //   );

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

  // Future<void> sharePostToCommunity({
  //   required String originalPostId,
  //   required String targetCommunityId,
  //   String? additionalContent,
  // }) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   final result = await feedRepo.addPostToCommunity(
  //     originalPostId: originalPostId,
  //     targetCommunityId: targetCommunityId,
  //     additionalContent: additionalContent,
  //   );

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

  // Future<void> removeCommunityPost(String postId) async {
  //   // Optimistic Update
  //   final originalFeed = state.feed;
  //   if (state.feed != null) {
  //     state = state.copyWith(
  //       feed: state.feed!.where((post) => post.id != postId).toList(),
  //     );
  //   }

  //   final result = await feedRepo.removePostFromCommunity(postId);

  //   result.fold(
  //     (failure) =>
  //         state = state.copyWith(feed: originalFeed, error: failure.message),
  //     (_) => null, // Stay with optimistic update
  //   );
  // }

  // Future<void> fetchCommunityPosts(String communityId) async {
  //   state = state.copyWith(isLoading: true, isFirstLoad: true, error: null);
  //   final result = await feedRepo.getCommunityPosts(communityId: communityId);

  //   result.fold(
  //     (failure) => state = state.copyWith(
  //       isLoading: false,
  //       isFirstLoad: false,
  //       error: failure.message,
  //     ),
  //     (feed) => state = state.copyWith(
  //       feed: feed,
  //       isLoading: false,
  //       isFirstLoad: false,
  //       isEnd: feed.length < 20,
  //     ),
  //   );
  // }
}
