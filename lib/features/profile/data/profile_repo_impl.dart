import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/data/data_source.dart';
import 'package:mini_reddit_v2/features/profile/domain/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileDataSource dataSource;

  ProfileRepoImpl(this.dataSource);

  @override
  Future<Either<Failure, UserProfileModel>> getProfile(String userId) async {
    try {
      return Right(await dataSource.getProfile(userId));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    File? avatar,
    File? banner,
  }) async {
    // upload avatar image
    String? avatarUrl;
    if (avatar != null) {
      try {
        avatarUrl = await dataSource.uploadPostImage(avatar);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }

    // upload banner image
    String? bannerUrl;
    if (banner != null) {
      try {
        bannerUrl = await dataSource.uploadBannerImage(banner);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }

    // update profile
    try {
      return Right(
        await dataSource.updateProfile(
          userId: userId,
          username: username,
          fullName: fullName,
          bio: bio,
          avatarUrl: avatarUrl,
          bannerUrl: bannerUrl,
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getUserPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final posts = await dataSource.getUserPosts(
        userId: userId,
        limit: limit,
        offset: offset,
      );

      debugPrint('user posts: $posts');
      return Right(posts);
    } catch (e) {
      debugPrint('error in user posts: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileCommentItem>>> getUserComments({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final comments = await dataSource.getUserComments(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(comments);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedPostModel>>> getUserSavedPosts({
    required String userId,
    bool forceRefresh = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final posts = await dataSource.getUserSavedPosts(
        forceRefresh: true,
        userId: userId,
        limit: limit,
        offset: offset,
      );
      debugPrint('user saved posts: $posts');
      return Right(posts);
    } catch (e) {
      debugPrint('error in user saved posts: $e');
      return Left(Failure(e.toString()));
    }
  }
}
