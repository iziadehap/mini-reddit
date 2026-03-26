import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/services/supabase_services.dart';
import 'package:mini_reddit_v2/features/auth/data/auth_dataSources.dart';
import 'package:mini_reddit_v2/features/auth/data/auth_repo_impl.dart';
import 'package:mini_reddit_v2/features/auth/domain/auth_repo.dart';
import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_state.dart';

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
      state = state.copyWith(isLoading: true);
      final result = await authRepo.uploadProfileImage(image);
      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return null;
        },
        (imageUrl) {
          state = state.copyWith(isLoading: false);
          return imageUrl;
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
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
        (success) => state = state.copyWith(
          isLoading: false,
          isSignInSuccess: true,
          userProfileModel: success,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = state.copyWith(
        isLoading: true,
        isSignUpSuccess: false,
        clearError: true,
      );
      final result = await authRepo.signUp(email, password);
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (success) =>
            state = state.copyWith(isLoading: false, isSignUpSuccess: true),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
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
    try {
      state = state.copyWith(
        isLoading: true,
        isCompleteProfile: false,
        clearError: true,
      );
      final result = await authRepo.updateProfile(
        fullName: fullName,
        bio: bio,
        username: username,
        avatarUrl: avatarUrl,
      );

      if (result.isRight()) {
        // Fetch the updated profile to update userProfileModel
        await checkAuth();
        state = state.copyWith(isLoading: false, isCompleteProfile: true);
      } else {
        result.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
          (success) => null,
        );
      }
    } catch (e) {
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
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}









  // Future<void> verifyEmail(String email, String token) async {
  //   state = state.copyWith(isLoading: true, isSuccess: false);
  //   final result = await _authRepo.verifyOTP(email, token);
  //   result.fold(
  //     (failure) => state = state.copyWith(
  //       isLoading: false,
  //       errorMessage: failure.message,
  //     ),
  //     (success) => state = state.copyWith(isLoading: false, isSuccess: true),
  //   );
  // }
  //
  // Future<void> resendOtp(String email) async {
  //   state = state.copyWith(isLoading: true, isSuccess: false);
  //   final result = await _authRepo.resendOtp(email);
  //   result.fold(
  //     (failure) => state = state.copyWith(
  //       isLoading: false,
  //       errorMessage: failure.message,
  //     ),
  //     (success) => state = state.copyWith(isLoading: false),
  //   );
  // }
