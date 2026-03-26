import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/failure_model.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';

abstract class FeedRepo {
  Future<Either<Failure, List<FeedPostModel>>> getHotFeed({
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  });

  Future<Either<Failure, List<FeedPostModel>>> getNewFeed({
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  });

  Future<Either<Failure, List<FeedPostModel>>> getTopFeed({
    required TopFeedTimeframe timeframe,
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  });

  Future<Either<Failure, List<FeedPostModel>>> searchPosts({
    required String query,
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  });

  Future<Either<Failure, List<FeedPostModel>>> getBestFeed({
    int offset = 0,
    int limit = 10,
  });

  Future<Either<Failure, List<FeedPostModel>>> getPopularFeed({
    int offset = 0,
    int limit = 10,
  });

  Future<Either<Failure, List<FeedPostModel>>> getUserPosts({
    required String targetUserId,
    int offset = 0,
    int limit = 10,
  });

  Future<Either<Failure, List<FeedPostModel>>> getCommunityFeed({
    required String communityName,
    int offset = 0,
    int limit = 10,
  });

  // // Community Management Methods (Added to fix FeedProvider dependencies)
  // Future<Either<Failure, List<CommunityModel>>> getCommunities({
  //   int limit = 20,
  //   int offset = 0,
  //   String? search,
  // });

  // Future<Either<Failure, List<UserCommunityModel>>> getUserCommunities({
  //   required String userId,
  //   int limit = 20,
  //   int offset = 0,
  // });

  // Future<Either<Failure, Map<String, dynamic>>> createCommunity({
  //   required String name,
  //   String? description,
  //   String? imageUrl,
  //   String? bannerUrl,
  // });

  // Future<Either<Failure, Map<String, dynamic>>> joinCommunity(
  //   String communityId,
  // );

  // Future<Either<Failure, Map<String, dynamic>>> leaveCommunity(
  //   String communityId,
  // );

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

  // Future<Either<Failure, void>> removePostFromCommunity(String postId);

  // Future<Either<Failure, List<FeedPostModel>>> getCommunityPosts({
  //   required String communityId,
  //   int page = 1,
  //   int pageSize = 20,
  // });

  // Future<Either<Failure, String>> uploadCommunityImage(File file);
}
