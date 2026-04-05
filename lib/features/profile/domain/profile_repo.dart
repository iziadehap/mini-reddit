import 'dart:io';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepo {
  Future<Either<Failure, UserProfileModel>> getProfile();
  Future<Either<Failure, UserProfileModel>> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    File? avatar,
    File? banner,
  });

  Future<Either<Failure, List<FeedPostModel>>> getUserPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<UserProfileCommentItem>>> getUserComments({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<FeedPostModel>>> getUserSavedPosts({
    required String userId,
    bool forceRefresh = false,
    int limit = 20,
    int offset = 0,
  });
}
