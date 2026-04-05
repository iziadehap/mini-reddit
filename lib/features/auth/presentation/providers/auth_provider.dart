import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/services/cash.dart';
import 'package:mini_reddit_v2/core/services/supabase_services.dart';
import 'package:mini_reddit_v2/core/models/user_devices.dart';
import 'package:mini_reddit_v2/features/auth/data/auth_dataSources.dart';
import 'package:mini_reddit_v2/features/auth/data/auth_repo_impl.dart';
import 'package:mini_reddit_v2/features/auth/domain/auth_repo.dart';
import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_state.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier(authRepo: AuthRepoImpl(AuthDataSource()));
});

class AuthNotifier extends Notifier<AuthState> {
  final AuthRepo authRepo;

  AuthNotifier({required this.authRepo});

  // AuthRepo get _authRepo => ref.read(authRepoProvider);

  @override
  AuthState build() {
    // Proactively check auth state on start
    Future.microtask(() => checkAuth());
    return AuthState.initial();
  }

  Future<void> checkAuth() async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user != null) {
      state = state.copyWith(isLoading: true, clearError: true);
      final result = await authRepo.getUserProfile();
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          isInitialAuthChecked: true,
        ),
        (profile) => state = state.copyWith(
          isLoading: false,
          userProfileModel: profile,
          isInitialAuthChecked: true,
        ),
      );
    } else {
      state = state.copyWith(isInitialAuthChecked: true);
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      debugPrint('🔍 uploadImage called for file: ${image.path}');
      state = state.copyWith(isLoading: true, clearError: true);

      // Check if user is authenticated
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User is not authenticated for image upload');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User is not authenticated. Please sign in again.',
        );
        return null;
      }

      debugPrint('🔍 User authenticated: ${currentUser.id}');
      final result = await authRepo.uploadProfileImage(image);

      return result.fold(
        (failure) {
          debugPrint('❌ Image upload failed: ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return null;
        },
        (imageUrl) {
          debugPrint('✅ Image upload successful: $imageUrl');
          state = state.copyWith(isLoading: false);
          return imageUrl;
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error in uploadImage: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      // Clear all cash data before signing in
      await CashService().clear();

      state = state.copyWith(
        isLoading: true,
        isSignInSuccess: false,
        clearError: true,
      );
      final result = await authRepo.signIn(email, password);
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (success) async {
          state = state.copyWith(
            isLoading: false,
            isSignInSuccess: true,
            userProfileModel: success,
          );
          // Setup push notifications after successful sign in
          await setupPushNotifications();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      // Clear all cash data before signing up
      await CashService().clear();

      state = state.copyWith(
        isLoading: true,
        isSignUpSuccess: false,
        clearError: true,
      );

      // Direct Supabase signup for better control
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null && response.session == null) {
        // User signed up but email not verified - set state for verification
        state = state.copyWith(
          isLoading: false,
          needsEmailVerification: true,
          verificationEmail: email,
        );
      } else if (response.session != null) {
        // Email confirmation disabled or already verified
        final result = await authRepo.signIn(email, password);
        result.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
          (success) async {
            state = state.copyWith(
              isLoading: false,
              isSignUpSuccess: true,
              userProfileModel: success,
            );
            await setupPushNotifications();
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error in signUp: $e');

      // Handle rate limit exception
      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        // Check if the message contains specific wait time
        final timeRegex = RegExp(r'after (\d+) seconds');
        final timeMatch = timeRegex.firstMatch(errorMessage);

        if (timeMatch != null) {
          // Extract specific wait time from message
          final waitTime = timeMatch.group(1) ?? '60';
          errorMessage =
              '⏰ Too many requests. Please wait $waitTime seconds before trying again.';
        } else {
          // Use default wait time when no specific time is mentioned
          errorMessage =
              '⏰ Too many requests. Please wait 60 seconds before trying again.';
        }
      }
      debugPrint('❌ Final error message: $errorMessage');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Error toString: ${e.toString()}');

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<bool> isAlreadyLoggedIn() async {
    return await authRepo.isAlreadyLoggedIn();
  }

  Future<void> completeProfile({
    required String fullName,
    required String bio,
    required String username,
    String? avatarUrl,
  }) async {
    debugPrint('🔍 completeProfile called');
    debugPrint('🔍 - fullName: $fullName');
    debugPrint('🔍 - bio: $bio');
    debugPrint('🔍 - username: $username');
    debugPrint('🔍 - avatarUrl: $avatarUrl');

    try {
      state = state.copyWith(
        isLoading: true,
        isCompleteProfile: false,
        clearError: true,
      );

      // Check username availability first
      debugPrint('🔍 Checking username availability...');
      final usernameCheck = await authRepo.isUsernameAvailable(username);

      usernameCheck.fold(
        (failure) {
          debugPrint('❌ Username check failed: ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return;
        },
        (isAvailable) {
          if (!isAvailable) {
            debugPrint('❌ Username not available: $username');
            state = state.copyWith(
              isLoading: false,
              errorMessage:
                  'Username "$username" is already taken. Please choose a different username.',
            );
            return;
          }
          debugPrint('✅ Username is available: $username');
        },
      );

      debugPrint('🔍 Calling authRepo.updateProfile...');
      final result = await authRepo.updateProfile(
        fullName: fullName,
        bio: bio,
        username: username,
        avatarUrl: avatarUrl,
      );

      debugPrint('🔍 Profile update result: $result');

      if (result.isRight()) {
        debugPrint('🔍 Profile update successful, calling checkAuth...');
        // Fetch the updated profile to update userProfileModel
        await checkAuth();
        debugPrint('🔍 checkAuth completed, setting isCompleteProfile to true');
        state = state.copyWith(isLoading: false, isCompleteProfile: true);
      } else {
        debugPrint('❌ Profile update failed');
        result.fold((failure) {
          debugPrint('❌ Failure message: ${failure.message}');

          // Check if it's a duplicate username error
          String userFriendlyMessage = failure.message;
          if (failure.message.contains(
                'duplicate key value violates unique constraint',
              ) &&
              failure.message.contains('username')) {
            userFriendlyMessage =
                'Username "${username}" is already taken. Please choose a different username.';
          }

          state = state.copyWith(
            isLoading: false,
            errorMessage: userFriendlyMessage,
          );
        }, (success) => null);
      }
    } catch (e) {
      debugPrint('❌ Error in completeProfile: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final result = await authRepo.signOut();
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (success) => state = state.copyWith(
          isLoading: false,
          isCompleteProfile: false,
          isSignInSuccess: false,
          isSignUpSuccess: false,
          clearProfile: true,
        ),
      );

      clearAllProviders(ref);

      // Clear all cash data
      await CashService().clear();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Push notification methods
  Future<void> setupPushNotifications() async {
    try {
      final result = await authRepo.setupPushNotifications();
      result.fold(
        (failure) => state = state.copyWith(errorMessage: failure.message),
        (success) => null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<Map<String, dynamic>?> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    try {
      final result = await authRepo.registerDevice(
        fcmToken: fcmToken,
        platform: platform,
      );
      return result.fold((failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      }, (deviceData) => deviceData);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<void> unregisterDevice({required String fcmToken}) async {
    try {
      final result = await authRepo.unregisterDevice(fcmToken: fcmToken);
      result.fold(
        (failure) => state = state.copyWith(errorMessage: failure.message),
        (success) => null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<List<UserDevice>?> getUserDevices() async {
    try {
      final result = await authRepo.getUserDevices();
      return result.fold((failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      }, (devices) => devices);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  // Password reset methods
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      state = state.copyWith(isLoading: false, passwordResetEmailSent: true);
    } catch (e) {
      debugPrint('❌ Error in sendPasswordResetEmail: $e');

      // Handle rate limit exception
      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        // Check if the message contains specific wait time
        final timeRegex = RegExp(r'after (\d+) seconds');
        final timeMatch = timeRegex.firstMatch(errorMessage);

        if (timeMatch != null) {
          // Extract specific wait time from message
          final waitTime = timeMatch.group(1) ?? '60';
          errorMessage =
              '⏰ Too many requests. Please wait $waitTime seconds before trying again.';
        } else {
          // Use default wait time when no specific time is mentioned
          errorMessage =
              '⏰ Too many requests. Please wait 60 seconds before trying again.';
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<void> verifyPasswordResetOTP(String email, String otp) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      state = state.copyWith(isLoading: false, passwordResetOTPVerified: true);
    } catch (e) {
      debugPrint('❌ Error in` verifyPasswordResetOTP: $e');

      // Handle rate limit exception
      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        // Check if the message contains specific wait time
        final timeRegex = RegExp(r'after (\d+) seconds');
        final timeMatch = timeRegex.firstMatch(errorMessage);

        if (timeMatch != null) {
          // Extract specific wait time from message
          final waitTime = timeMatch.group(1) ?? '60';
          errorMessage =
              '⏰ Too many requests. Please wait $waitTime seconds before trying again.';
        } else {
          // Use default wait time when no specific time is mentioned
          errorMessage =
              '⏰ Too many requests. Please wait 60 seconds before trying again.';
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      state = state.copyWith(isLoading: false, passwordUpdated: true);
    } catch (e) {
      debugPrint('❌ Error in updatePassword: $e');

      // Handle rate limit exception
      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        // Check if the message contains specific wait time
        final timeRegex = RegExp(r'after (\d+) seconds');
        final timeMatch = timeRegex.firstMatch(errorMessage);

        if (timeMatch != null) {
          // Extract specific wait time from message
          final waitTime = timeMatch.group(1) ?? '60';
          errorMessage =
              '⏰ Too many requests. Please wait $waitTime seconds before trying again.';
        } else {
          // Use default wait time when no specific time is mentioned
          errorMessage =
              '⏰ Too many requests. Please wait 60 seconds before trying again.';
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  // Email verification methods
  Future<void> verifyEmailOTP(String email, String otp) async {
    debugPrint('🔍 verifyEmailOTP called with email: $email, otp: $otp');
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      debugPrint('🔍 Calling Supabase.verifyOTP...');
      final result = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );
      debugPrint('🔍 Supabase.verifyOTP result: $result');
      debugPrint('🔍 User after OTP: ${result.user}');
      debugPrint('🔍 Session after OTP: ${result.session}');

      // After successful OTP verification, the user should be automatically signed in
      // No need to call signIn again - verifyOTP creates the session
      if (result.session != null && result.user != null) {
        debugPrint('🔍 OTP verification successful, user is signed in');

        // Get user profile data
        final profileResult = await authRepo.getUserProfile();
        profileResult.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
          (userProfile) async {
            debugPrint('🔍 User profile loaded: $userProfile');
            state = state.copyWith(
              isLoading: false,
              isSignInSuccess: true,
              userProfileModel: userProfile,
              needsEmailVerification: false,
            );
            await setupPushNotifications();
          },
        );
      } else {
        debugPrint('❌ OTP verification failed - no session created');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Email verification failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error in verifyEmailOTP: $e');

      // Handle rate limit exception
      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        // Check if the message contains specific wait time
        final timeRegex = RegExp(r'after (\d+) seconds');
        final timeMatch = timeRegex.firstMatch(errorMessage);

        if (timeMatch != null) {
          // Extract specific wait time from message
          final waitTime = timeMatch.group(1) ?? '60';
          errorMessage =
              '⏰ Too many requests. Please wait $waitTime seconds before trying again.';
        } else {
          // Use default wait time when no specific time is mentioned
          errorMessage =
              '⏰ Too many requests. Please wait 60 seconds before trying again.';
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<void> resendEmailVerification(String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('❌ Error in resendEmailVerification: $e');

      // Handle rate limit exception
      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        // Check if the message contains specific wait time
        final timeRegex = RegExp(r'after (\d+) seconds');
        final timeMatch = timeRegex.firstMatch(errorMessage);

        if (timeMatch != null) {
          // Extract specific wait time from message
          final waitTime = timeMatch.group(1) ?? '60';
          errorMessage =
              '⏰ Too many requests. Please wait $waitTime seconds before trying again.';
        } else {
          // Use default wait time when no specific time is mentioned
          errorMessage =
              '⏰ Too many requests. Please wait 60 seconds before trying again.';
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  void clearAllProviders(Ref ref) {
    ref.invalidate(profileProvider);
    ref.invalidate(myProfileProvider);
    ref.invalidate(postProvider);
    ref.invalidate(feedProvider);
  }
}
