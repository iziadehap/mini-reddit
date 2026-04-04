import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/user_devices.dart';
import 'package:mini_reddit_v2/core/utils/auth_error_handler.dart';
import 'package:mini_reddit_v2/features/auth/data/auth_dataSources.dart';
import 'package:mini_reddit_v2/features/auth/domain/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final authRepoProvider = Provider<AuthRepo>((ref) {
//   final dataSource = ref.watch(authDataSourceProvider);
//   return AuthRepoImpl(dataSource);
// });

class AuthRepoImpl implements AuthRepo {
  final AuthDataSource _authDataSource;

  AuthRepoImpl(this._authDataSource);

  @override
  Future<Either<Failure, bool>> signUp(String email, String password) async {
    try {
      await _authDataSource.signUp(email: email, password: password);
      // check is email
      return const Right(true);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to sign up'));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> signIn(
    String email,
    String password,
  ) async {
    try {
      await _authDataSource.signIn(email: email, password: password);
      final profileData = await _authDataSource.getMyProfile();

      if (profileData == null) {
        return Left(Failure('Profile not found'));
      }
      UserProfileModel profileModel = UserProfileModel.fromJson(profileData);

      return Right(profileModel);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to sign in'));
    }
  }

  Future<Either<Failure, List<UserDevice>>> getUserDevices() async {
    try {
      final result = await _authDataSource.getUserDevices();
      debugPrint("result: $result");
      return Right(
        (result as List).map((e) => UserDevice.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint("error get user device: $e");
      return Left(AuthErrorHandler.handle(e, 'Failed to get user devices'));
    }
  }

  @override
  Future<Either<Failure, void>> setupPushNotifications() async {
    try {
      await _authDataSource.setupPushNotifications();
      return const Right(null);
    } catch (e) {
      return Left(
        AuthErrorHandler.handle(e, 'Failed to setup push notifications'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    try {
      final result = await _authDataSource.registerDevice(
        fcmToken: fcmToken,
        platform: platform,
      );
      return Right(result);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to register device'));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterDevice({
    required String fcmToken,
  }) async {
    try {
      await _authDataSource.unregisterDevice(fcmToken: fcmToken);
      return const Right(null);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to unregister device'));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile() async {
    try {
      final profileData = await _authDataSource.getMyProfile();
      if (profileData == null) {
        return Left(Failure('Profile not found'));
      }
      UserProfileModel profileModel = UserProfileModel.fromJson(profileData);
      return Right(profileModel);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to get profile'));
    }
  }

  @override
  Future<bool> isAlreadyLoggedIn() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null;
  }

  @override
  Future<Either<Failure, bool>> updateProfile({
    required String fullName,
    required String bio,
    required String username,
    String? avatarUrl,
  }) async {
    try {
      await _authDataSource.updateProfile(
        username: username,
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      return const Right(true);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to update profile'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File image) async {
    try {
      final result = await _authDataSource.uploadProfileImage(image);
      return Right(result);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to upload image'));
    }
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    try {
      await _authDataSource.signOut();
      return const Right(true);
    } catch (e) {
      return Left(AuthErrorHandler.handle(e, 'Failed to sign out'));
    }
  }

  // @override
  // Future<Either<Failure, bool>> resendOtp(String email) async {
  //   try {
  //     await _authDataSource.resendOtp(email);
  //     return const Right(true);
  //   } catch (e) {
  //     return Left(AuthErrorHandler.handle(e, 'Failed to resend OTP'));
  //   }
  // }
  //
  // @override
  // Future<Either<Failure, bool>> verifyOTP(String email, String token) async {
  //   try {
  //     await _authDataSource.verifyEmailOtp(email: email, token: token);
  //     return const Right(true);
  //   } catch (e) {
  //     return Left(AuthErrorHandler.handle(e, 'Verification failed'));
  //   }
  // }
}
