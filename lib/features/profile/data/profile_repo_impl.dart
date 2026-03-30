import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/data/data_source.dart';
import 'package:mini_reddit_v2/features/profile/domain/profile_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileDataSource dataSource;

  ProfileRepoImpl(this.dataSource);

  @override
  Future<Either<Failure, UserProfileModel>> getProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
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
  }) async {
    // uplode image
    String? avatarUrl;
    if (avatar != null) {
      try {
        avatarUrl = await dataSource.uploadPostImage(avatar);
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
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
