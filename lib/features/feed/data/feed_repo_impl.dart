import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/feed/data/DataSource/feed_data_source.dart';
import 'package:mini_reddit_v2/features/feed/domain/feed_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedRepoImpl implements FeedRepo {
  final FeedDataSource _dataSource;
  final CommunitiesDataSource _communitiesDataSource;
  final SupabaseClient _supabase = Supabase.instance.client;

  FeedRepoImpl(this._dataSource, this._communitiesDataSource);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<FeedPostModel>>> getHotFeed({
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    try {
      final posts = await _dataSource.getHotFeed(
        offset: offset,
        limit: limit,
        communityNames: communityNames,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getNewFeed({
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    try {
      final posts = await _dataSource.getNewFeed(
        offset: offset,
        limit: limit,
        communityNames: communityNames,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getTopFeed({
    required TopFeedTimeframe timeframe,
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    try {
      final posts = await _dataSource.getTopFeed(
        timeframe: timeframe.value,
        offset: offset,
        limit: limit,
        communityNames: communityNames,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> searchPosts({
    required String query,
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    try {
      final posts = await _dataSource.searchPosts(
        query: query,
        offset: offset,
        limit: limit,
        communityNames: communityNames,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getBestFeed({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      if (_currentUserId == null) {
        return Left(Failure('User not logged in'));
      }
      final posts = await _dataSource.getBestFeed(
        userId: _currentUserId!,
        offset: offset,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getPopularFeed({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final posts = await _dataSource.getPopularFeed(
        offset: offset,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      print('error when get popular feed: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getUserPosts({
    required String targetUserId,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final posts = await _dataSource.getUserPosts(
        targetUserId: targetUserId,
        offset: offset,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getCommunityFeed({
    required String communityName,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final posts = await _dataSource.getCommunityFeed(
        communityName: communityName,
        offset: offset,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // // Community Management Implementation
  // @override
  // Future<Either<Failure, List<CommunityModel>>> getCommunities({
  //   int limit = 20,
  //   int offset = 0,
  //   String? search,
  // }) async {
  //   try {
  //     final res = await _communitiesDataSource.getCommunities(
  //       limit: limit,
  //       offset: offset,
  //       search: search,
  //     );
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, List<UserCommunityModel>>> getUserCommunities({
  //   required String userId,
  //   int limit = 20,
  //   int offset = 0,
  // }) async {
  //   try {
  //     final res = await _communitiesDataSource.getUserCommunities(
  //       userId: userId,
  //       limit: limit,
  //       offset: offset,
  //     );
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, Map<String, dynamic>>> createCommunity({
  //   required String name,
  //   String? description,
  //   String? imageUrl,
  //   String? bannerUrl,
  // }) async {
  //   try {
  //     final res = await _communitiesDataSource.createCommunity(
  //       name: name,
  //       description: description,
  //       imageUrl: imageUrl,
  //       bannerUrl: bannerUrl,
  //     );
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, Map<String, dynamic>>> joinCommunity(
  //   String communityId,
  // ) async {
  //   try {
  //     final res = await _communitiesDataSource.joinCommunity(communityId);
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, Map<String, dynamic>>> leaveCommunity(
  //   String communityId,
  // ) async {
  //   try {
  //     final res = await _communitiesDataSource.leaveCommunity(communityId);
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, FeedPostModel>> createPostInCommunity({
  //   required String communityId,
  //   required String title,
  //   required String content,
  //   String postType = 'text',
  //   String? linkUrl,
  //   String? flairId,
  //   List<String>? imageUrls,
  // }) async {
  //   try {
  //     final res = await _communitiesDataSource.createPostInCommunity(
  //       communityId: communityId,
  //       title: title,
  //       content: content,
  //       postType: postType,
  //       linkUrl: linkUrl,
  //       flairId: flairId,
  //       imageUrls: imageUrls,
  //     );
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, FeedPostModel>> addPostToCommunity({
  //   required String originalPostId,
  //   required String targetCommunityId,
  //   String? additionalContent,
  // }) async {
  //   try {
  //     final res = await _communitiesDataSource.addPostToCommunity(
  //       originalPostId: originalPostId,
  //       targetCommunityId: targetCommunityId,
  //       additionalContent: additionalContent,
  //     );
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, void>> removePostFromCommunity(String postId) async {
  //   try {
  //     await _communitiesDataSource.removePostFromCommunity(postId);
  //     return const Right(null);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, List<FeedPostModel>>> getCommunityPosts({
  //   required String communityId,
  //   int page = 1,
  //   int pageSize = 20,
  // }) async {
  //   try {
  //     final res = await _communitiesDataSource.getCommunityPosts(
  //       communityId: communityId,
  //       page: page,
  //       pageSize: pageSize,
  //     );
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, String>> uploadCommunityImage(File file) async {
  //   try {
  //     final res = await _communitiesDataSource.uploadCommunityImage(file);
  //     return Right(res);
  //   } catch (e) {
  //     return Left(Failure(e.toString()));
  //   }
  // }
}
