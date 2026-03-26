import 'package:mini_reddit_v2/core/models/models.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSignInSuccess;
  final bool isSignUpSuccess;
  final bool isCompleteProfile;
  final UserProfileModel? userProfileModel;
  final bool isInitialAuthChecked;

  AuthState({
    required this.isLoading,
    this.errorMessage,
    this.isSignInSuccess = false,
    this.isSignUpSuccess = false,
    this.isCompleteProfile = false,
    this.userProfileModel,
    this.isInitialAuthChecked = false,
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
    );
  }
}