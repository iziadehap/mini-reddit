import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_repo_impl.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';

final fetchCommunityPostsProvider =
    StateNotifierProvider<
      FetchCommunityPostsNotifier,
      AsyncValue<List<FeedPostModel>>
    >((ref) {
      return FetchCommunityPostsNotifier(
        communitiesRepo: CommunitiesRepoImpl(CommunitiesDataSource()),
      );
    });

class FetchCommunityPostsNotifier
    extends StateNotifier<AsyncValue<List<FeedPostModel>>> {
  final CommunitiesRepo communitiesRepo;

  FetchCommunityPostsNotifier({required this.communitiesRepo})
    : super(const AsyncValue.loading());

  Future<void> fetchCommunityPosts(String communityId) async {
    state = const AsyncValue.loading();
    final result = await communitiesRepo.getCommunityPosts(
      communityId: communityId,
    );
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (feed) => state = AsyncValue.data(feed),
    );
  }
}
