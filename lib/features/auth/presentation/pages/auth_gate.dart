// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mini_reddit_v2/core/widgets/main_navigation_layout.dart';
// import 'package:mini_reddit_v2/features/auth/presentation/pages/login_screen.dart';
// import 'package:mini_reddit_v2/features/auth/presentation/pages/splash_screen.dart';
// import 'package:mini_reddit_v2/features/auth/presentation/pages/complete_profile_screen.dart';
// import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_provider.dart';

// class AuthGate extends ConsumerWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);

//     // Initial loading or splash - only show if initial check hasn't finished
//     if (!authState.isInitialAuthChecked) {
//       return const SplashScreen();
//     }

//     // If authenticated and profile exists
//     if (authState.userProfileModel != null) {
//       return const MainNavigationLayout();
//     }

//     // If "Profile not found" error occurred during login/start
//     if (authState.errorMessage == 'Profile not found') {
//       return const CompleteProfileScreen();
//     }

//     // Default to Login
//     return const LoginScreen();
//   }
// }
