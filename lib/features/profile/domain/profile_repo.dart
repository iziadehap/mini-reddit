import 'dart:io';

import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

abstract class ProfileRepo {
  Future<Either<Failure, UserProfileModel>> getProfile();
  Future<Either<Failure, UserProfileModel>> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    File? avatar,
  });
}
