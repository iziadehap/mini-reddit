import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

abstract class AuthRepo {
  Future<Either<Failure, bool>> signUp(String email, String password);
  Future<bool> isAlreadyLoggedIn();
  Future<Either<Failure, UserProfileModel>> signIn(
    String email,
    String password,
  );
  // Future<Either<Failure, bool>> resendOtp(String email);
  // Future<Either<Failure, bool>> verifyOTP(String email, String token);
  Future<Either<Failure, bool>> updateProfile({
    required String fullName,
    required String bio,
    required String username,
    String? avatarUrl,
  });

  Future<Either<Failure, UserProfileModel>> getUserProfile();
  Future<Either<Failure, String>> uploadProfileImage(File image);
  Future<Either<Failure, bool>> signOut();
}
