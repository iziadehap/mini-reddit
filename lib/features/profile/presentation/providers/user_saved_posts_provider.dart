import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/data/data_source.dart';
import 'package:mini_reddit_v2/features/profile/data/profile_repo_impl.dart';
import 'package:mini_reddit_v2/features/profile/domain/profile_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPostsRepositoryProvider = Provider<ProfileRepo>((ref) {
  return ProfileRepoImpl(ProfileDataSource());
});

final userSavedPostsProvider =
    StateNotifierProvider<
      UserSavedPostsNotifier,
      AsyncValue<List<FeedPostModel>>
    >((ref) {
      return UserSavedPostsNotifier(ref.read(savedPostsRepositoryProvider));
    });

class UserSavedPostsNotifier
    extends StateNotifier<AsyncValue<List<FeedPostModel>>> {
  final ProfileRepo _repo;

  UserSavedPostsNotifier(this._repo) : super(const AsyncValue.loading()) {
    // fetchSavedPosts();
  }

  Future<void> fetchSavedPosts({bool forceRefresh = false}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = AsyncValue.error('Not signed in', StackTrace.current);
      return;
    }

    // if (!forceRefresh && state is AsyncData<List<FeedPostModel>>) {
    //   return;
    // }

    // if (forceRefresh) {
    //   state = const AsyncValue.loading();
    // }

    final result = await _repo.getUserSavedPosts(
      userId: userId,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (posts) {
        debugPrint('saved posts ====: $posts');
        return state = AsyncValue.data(posts);
      },
    );
  }
}
