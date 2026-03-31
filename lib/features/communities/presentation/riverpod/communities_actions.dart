import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_repo_impl.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_communities_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/user_communities_provider.dart';

final communitiesActionsProvider =
    StateNotifierProvider<
      CommunitiesActionsNotifier,
      AsyncValue<List<CommunityModel>>
    >((ref) {
      return CommunitiesActionsNotifier(
        ref: ref,
        communitiesRepo: CommunitiesRepoImpl(
          communitiesDataSource: CommunitiesDataSource(),
        ),
      );
    });

class CommunitiesActionsNotifier
    extends StateNotifier<AsyncValue<List<CommunityModel>>> {
  final Ref ref;
  final CommunitiesRepo communitiesRepo;

  CommunitiesActionsNotifier({required this.ref, required this.communitiesRepo})
    : super(const AsyncValue.loading());

  Future<void> joinCommunity(String communityId) async {
    final data = await communitiesRepo.joinCommunity(communityId);
    data.fold((failure) => setError(failure.message), (_) {
      ref.read(userCommunitiesProvider.notifier).clearCache();
      resetFetchCommunities();
    });
  }

  Future<void> leaveCommunity(String communityId) async {
    final data = await communitiesRepo.leaveCommunity(communityId);
    data.fold((failure) => setError(failure.message), (_) {
      ref.read(userCommunitiesProvider.notifier).clearCache();
      resetFetchCommunities();
    });
  }

  Future<Map<String, dynamic>?> createCommunity({
    required String name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
  }) async {
    final data = await communitiesRepo.createCommunity(
      name: name,
      description: description,
      imageUrl: imageUrl,
      bannerUrl: bannerUrl,
    );
    return data.fold(
      (failure) {
        setError(failure.message);
        return {'success': false, 'message': failure.message};
      },
      (successResult) {
        ref.read(userCommunitiesProvider.notifier).clearCache();
        resetFetchCommunities();
        return successResult;
      },
    );
  }

  Future<String?> uploadCommunityImage(File file) async {
    final result = await communitiesRepo.uploadCommunityImage(file);
    return result.fold((failure) {
      state = AsyncValue.error(failure.message, StackTrace.current);
      return null;
    }, (url) => url);
  }

  Future<void> removePost(String postId) async {
    final result = await communitiesRepo.removePostFromCommunity(postId);
    result.fold((failure) => setError(failure.message), (_) {
      // Post removal is usually followed by a refresh in the screen list
      debugPrint('Post $postId removed successfully');
    });
  }

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
  //   setLoading();
  //   final result = await communitiesRepo.createPostInCommunity(
  //     communityId: communityId,
  //     title: title,
  //     content: content,
  //     imageUrls: imageUrls,
  //     postType: postType,
  //     flairId: flairId,
  //   );
  //
  //   result.fold((failure) => setError(failure.message), (newPost) {
  //     final currentFeed = state.value ?? [];
  //     state = AsyncValue.data([newPost, ...currentFeed]);
  //   });
  // }
  //
  //  Future<List<String>> uploadPostImage(List<File> imageFiles) async {
  //   final result = await postRepo.uploadPostImage(imageFiles);
  //   return result.fold((failure) {
  //     state = state.copyWith(error: failure.message);
  //     return [];
  //   }, (urls) => urls);
  // }
  // ---------------

  void resetFetchCommunities() {
    ref.read(fetchCommunitiesProvider.notifier).clearCache();
  }

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
