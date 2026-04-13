import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/communities/domain/communities_repo.dart';

class CommunitiesRepoImpl implements CommunitiesRepo {
  final CommunitiesDataSource _communitiesDataSource;

  CommunitiesRepoImpl({required CommunitiesDataSource communitiesDataSource})
      : _communitiesDataSource = communitiesDataSource;

  // Community Management Implementation
  @override
  Future<Either<Failure, List<CommunityModel>>> getCommunities({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    try {
      final res = await _communitiesDataSource.getCommunities(
        limit: limit,
        offset: offset,
        search: search,
      );
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommunityDetailsModel?>> getCommunityDetails(
    String communityId,
  ) async {
    try {
      final res = await _communitiesDataSource.getCommunityDetails(communityId);
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserCommunityModel>>> getUserCommunities({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final res = await _communitiesDataSource.getUserCommunities(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createCommunity({
    required String name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
  }) async {
    try {
      final res = await _communitiesDataSource.createCommunity(
        name: name,
        description: description,
        imageUrl: imageUrl,
        bannerUrl: bannerUrl,
      );
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinCommunity(
    String communityId,
  ) async {
    try {
      final res = await _communitiesDataSource.joinCommunity(communityId);
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> leaveCommunity(
    String communityId,
  ) async {
    try {
      final res = await _communitiesDataSource.leaveCommunity(communityId);
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getCommunityPosts({
    required String communityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await _communitiesDataSource.getCommunityPosts(
        communityId: communityId,
        page: page,
        pageSize: pageSize,
      );
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCommunityImage(File file) async {
    try {
      final res = await _communitiesDataSource.uploadCommunityImage(file);
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> editCommunity({
    required String communityId,
    required String name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
  }) async {
    try {
      final res = await _communitiesDataSource.editCommunity(
        communityId: communityId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        bannerUrl: bannerUrl,
      );
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removePostFromCommunity(String postId) async {
    try {
      await _communitiesDataSource.removePostFromCommunity(postId);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
