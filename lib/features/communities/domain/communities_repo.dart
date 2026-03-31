import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

abstract class CommunitiesRepo {
  // Community Management Methods (Added to fix FeedProvider dependencies)
  Future<Either<Failure, List<CommunityModel>>> getCommunities({
    int limit = 20,
    int offset = 0,
    String? search,
  });

  Future<Either<Failure, CommunityDetailsModel?>> getCommunityDetails(
    String communityId,
  );

  Future<Either<Failure, List<UserCommunityModel>>> getUserCommunities({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, Map<String, dynamic>>> createCommunity({
    required String name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
  });

  Future<Either<Failure, Map<String, dynamic>>> joinCommunity(
    String communityId,
  );

  Future<Either<Failure, Map<String, dynamic>>> leaveCommunity(
    String communityId,
  );

  // Future<Either<Failure, FeedPostModel>> createPostInCommunity({
  //   required String communityId,
  //   required String title,
  //   required String content,
  //   String postType = 'text',
  //   String? linkUrl,
  //   String? flairId,
  //   List<String>? imageUrls,
  // });

  // Future<Either<Failure, FeedPostModel>> addPostToCommunity({
  //   required String originalPostId,
  //   required String targetCommunityId,
  //   String? additionalContent,
  // });

  Future<Either<Failure, void>> removePostFromCommunity(String postId);

  Future<Either<Failure, List<FeedPostModel>>> getCommunityPosts({
    required String communityId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, String>> uploadCommunityImage(File file);

  Future<Either<Failure, SuccessModel>> editCommunity({
    required String communityId,
    required String name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
  });
}
