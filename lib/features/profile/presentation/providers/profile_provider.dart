import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/data/data_source.dart';
import 'package:mini_reddit_v2/features/profile/data/profile_repo_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Profile Provider using StateNotifierProvider.family
final profileProvider =
    StateNotifierProvider.family<
      ProfileNotifier,
      AsyncValue<UserProfileModel>,
      String
    >((ref, userId) {
      final repo = ProfileRepoImpl(ProfileDataSource());
      return ProfileNotifier(repo: repo, userId: userId);
    });

// Provider for the current logged in user's profile
final myProfileProvider = Provider<AsyncValue<UserProfileModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const AsyncValue.loading();
  return ref.watch(profileProvider(userId));
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfileModel>> {
  final ProfileRepoImpl _repo;
  final String _userId;

  ProfileNotifier({required ProfileRepoImpl repo, required String userId})
    : _repo = repo,
      _userId = userId,
      super(const AsyncValue.loading());

  Future<void> getProfile() async {
    // Only set loading if it's the first time or we want to refresh
    if (state is! AsyncData) {
      state = const AsyncValue.loading();
    }

    final response = await _repo.getProfile(_userId);
    response.fold(
      (l) => state = AsyncValue.error(l.message, StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    File? avatar,
    File? banner,
  }) async {
    state = const AsyncValue.loading();
    final response = await _repo.updateProfile(
      userId: _userId,
      username: username,
      fullName: fullName,
      bio: bio,
      avatar: avatar,
      banner: banner,
    );
    response.fold(
      (l) => state = AsyncValue.error(l.message, StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }
}
