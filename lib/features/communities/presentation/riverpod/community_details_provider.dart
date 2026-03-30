import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/community_details.dart';
import 'package:mini_reddit_v2/core/models/snackbar_model.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_repo_impl.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';

final communityDetailsProvider =
    StateNotifierProvider<
      CommunityDetailsNotifier,
      AsyncValue<CommunityDetailsModel>
    >((ref) {
      return CommunityDetailsNotifier(
        communitiesRepo: CommunitiesRepoImpl(
          communitiesDataSource: CommunitiesDataSource(),
        ),
        ref: ref,
      );
    });

class CommunityDetailsNotifier
    extends StateNotifier<AsyncValue<CommunityDetailsModel>> {
  final Ref ref;
  final CommunitiesRepo _communitiesRepo;
  CommunityDetailsNotifier({
    required CommunitiesRepo communitiesRepo,
    required this.ref,
  }) : _communitiesRepo = communitiesRepo,
       super(const AsyncLoading());

  Future<void> fetchCommunityDetails(String communityName) async {
    setLoading();
    final result = await _communitiesRepo.getCommunityDetails(communityName);
    result.fold(
      (failure) => setError(failure.message),
      (communityDetails) => setData(communityDetails!),
    );
  }

  Future<void> editCommunity({
    required String communityId,
    required String name,
    String? description,
    String? bannerUrl,
    String? imageUrl,
    bool? isPublic,
    bool? isNSFW,
  }) async {
    setLoading();
    final result = await _communitiesRepo.editCommunity(
      communityId: communityId,
      name: name,
      description: description,
      bannerUrl: bannerUrl,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) {
        setError(failure.message);
        ref.read(SuccessEditCommunityProvider.notifier).state = SnackBarModel(
          message: failure.message,
          isError: true,
        );
      },
      (communityDetails) {
        ref.read(SuccessEditCommunityProvider.notifier).state = SnackBarModel(
          message: 'Community updated successfully!',
          isError: false,
        );
      },
    );
  }

  // ======= state helper ======

  void setLoading() {
    state = const AsyncLoading();
  }

  void setError(String error) {
    state = AsyncError(error, StackTrace.current);
  }

  void setData(CommunityDetailsModel communityDetails) {
    state = AsyncData(communityDetails);
  }
}

final SuccessEditCommunityProvider = StateProvider<SnackBarModel?>(
  (ref) => null,
);
