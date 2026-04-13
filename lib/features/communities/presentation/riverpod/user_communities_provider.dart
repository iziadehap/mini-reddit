import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_repo_impl.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userCommunitiesProvider =
    StateNotifierProvider<
      UserCommunitiesNotifier,
      AsyncValue<List<UserCommunityModel>>
    >((ref) {
      return UserCommunitiesNotifier(
        communitiesRepo: CommunitiesRepoImpl(
          communitiesDataSource: CommunitiesDataSource(),
        ),
      );
    });

class UserCommunitiesNotifier
    extends StateNotifier<AsyncValue<List<UserCommunityModel>>> {
  final CommunitiesRepo _communitiesRepo;

  UserCommunitiesNotifier({required CommunitiesRepo communitiesRepo})
    : _communitiesRepo = communitiesRepo,
      super(const AsyncValue.loading()) {
    fetchUserCommunities();
  }

  Future<void> fetchUserCommunities({bool forceRefresh = false}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setError(Exception("User not found"), StackTrace.current);
      return;
    }

    if (!forceRefresh &&
        (state is AsyncData && (state.value?.isNotEmpty ?? false))) {
      // Data is already cached and not empty
      return;
    }

    if (forceRefresh) {
      state = const AsyncValue.loading();
    }

    final result = await _communitiesRepo.getUserCommunities(userId: userId);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (communities) => state = AsyncValue.data(communities),
    );
  }

  void clearCache() {
    state = const AsyncValue.loading();
    fetchUserCommunities();
  }

  void setError(Exception error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}
