import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/data/data_source.dart';
import 'package:mini_reddit_v2/features/profile/data/profile_repo_impl.dart';
import 'package:mini_reddit_v2/features/profile/domain/profile_repo.dart';

final postRepositoryProvider = Provider<ProfileRepo>((ref) {
  return ProfileRepoImpl(ProfileDataSource());
});

final userPostsProvider = StateNotifierProvider.family<UserPostsNotifier,
    AsyncValue<List<FeedPostModel>>, String>((ref, userId) {
  return UserPostsNotifier(ref.read(postRepositoryProvider), userId);
});

class UserPostsNotifier extends StateNotifier<AsyncValue<List<FeedPostModel>>> {
  final ProfileRepo _repo;
  final String userId;

  UserPostsNotifier(this._repo, this.userId)
      : super(const AsyncValue.loading()) {
    fetchUserPosts(forceRefresh: true);
  }

  Future<void> fetchUserPosts({bool forceRefresh = false}) async {
    if (userId.isEmpty) {
      state = AsyncValue.error('Not signed in', StackTrace.current);
      return;
    }

    if (!forceRefresh && state is AsyncData) {
      return;
    }

    if (forceRefresh) {
      state = const AsyncValue.loading();
    }

    final result = await _repo.getUserPosts(userId: userId);
    result.fold((failure) {
      debugPrint('🔥 Error fetching user posts: ${failure.message}');
      return state = AsyncValue.error(failure.message, StackTrace.current);
    }, (posts) => state = AsyncValue.data(posts));
  }
}
