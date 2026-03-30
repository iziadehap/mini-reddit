import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/domain/profile_repo.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_posts_provider.dart';

final userCommentsProvider = StateNotifierProvider.family<
    UserCommentsNotifier,
    AsyncValue<List<UserProfileCommentItem>>,
    String>((ref, userId) {
      return UserCommentsNotifier(ref.read(postRepositoryProvider), userId);
    });

class UserCommentsNotifier
    extends StateNotifier<AsyncValue<List<UserProfileCommentItem>>> {
  final ProfileRepo _repo;
  final String userId;

  UserCommentsNotifier(this._repo, this.userId)
    : super(const AsyncValue.loading()) {
    fetchUserComments();
  }

  Future<void> fetchUserComments({bool forceRefresh = false}) async {
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

    final result = await _repo.getUserComments(userId: userId);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (comments) => state = AsyncValue.data(comments),
    );
  }
}
