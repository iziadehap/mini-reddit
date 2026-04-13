import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

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

}
