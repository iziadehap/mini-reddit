import 'package:mini_reddit_v2/core/models/models.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSignInSuccess;
  final bool isSignUpSuccess;
  final bool isCompleteProfile;
  final UserProfileModel? userProfileModel;
  final bool isInitialAuthChecked;
  final bool needsEmailVerification;
  final String? verificationEmail;
  final bool passwordResetEmailSent;
  final bool passwordResetOTPVerified;
  final bool passwordUpdated;

  AuthState({
    required this.isLoading,
    this.errorMessage,
    this.isSignInSuccess = false,
    this.isSignUpSuccess = false,
    this.isCompleteProfile = false,
    this.userProfileModel,
    this.isInitialAuthChecked = false,
    this.needsEmailVerification = false,
    this.verificationEmail,
    this.passwordResetEmailSent = false,
    this.passwordResetOTPVerified = false,
    this.passwordUpdated = false,
  });

  factory AuthState.initial() =>
      AuthState(isLoading: false, isInitialAuthChecked: false);

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSignInSuccess,
    bool? isSignUpSuccess,
    bool? isCompleteProfile,
    UserProfileModel? userProfileModel,
    bool? isInitialAuthChecked,
    bool clearError = false,
    bool clearProfile = false,
    bool? needsEmailVerification,
    String? verificationEmail,
    bool? passwordResetEmailSent,
    bool? passwordResetOTPVerified,
    bool? passwordUpdated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSignInSuccess: isSignInSuccess ?? this.isSignInSuccess,
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
      isCompleteProfile: isCompleteProfile ?? this.isCompleteProfile,
      userProfileModel: clearProfile
          ? null
          : (userProfileModel ?? this.userProfileModel),
      isInitialAuthChecked: isInitialAuthChecked ?? this.isInitialAuthChecked,
      needsEmailVerification:
          needsEmailVerification ?? this.needsEmailVerification,
      verificationEmail: verificationEmail ?? this.verificationEmail,
      passwordResetEmailSent:
          passwordResetEmailSent ?? this.passwordResetEmailSent,
      passwordResetOTPVerified:
          passwordResetOTPVerified ?? this.passwordResetOTPVerified,
      passwordUpdated: passwordUpdated ?? this.passwordUpdated,
    );
  }
}
