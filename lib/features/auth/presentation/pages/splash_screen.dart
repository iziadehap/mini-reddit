import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/theme_provider.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';
import 'package:mini_reddit_v2/core/widgets/main_navigation_layout.dart';
import 'package:mini_reddit_v2/features/auth/presentation/pages/login_screen.dart';
import 'package:mini_reddit_v2/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    _handelThemeMode();
    final isAlreadyLoggedIn =
        await ref.read(authProvider.notifier).isAlreadyLoggedIn();

    debugPrint('🔍 isAlreadyLoggedIn: $isAlreadyLoggedIn');

    if (isAlreadyLoggedIn) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      debugPrint('🔍 userId: $userId');

      if (userId != null) {
        try {
          await ref.read(profileProvider(userId).notifier).getProfile();
          final profile = ref.read(profileProvider(userId));
          debugPrint('🔍 Profile loaded: ${profile.value}');

          // Check if profile is complete
          bool isProfileComplete = false;
          if (profile is AsyncData) {
            final userProfile = profile.value;
            isProfileComplete = userProfile?.fullName?.isNotEmpty == true &&
                userProfile?.username.isNotEmpty == true;
          } else if (profile is AsyncError) {
            debugPrint('🔍 Profile load error: ${profile.error}');
            isProfileComplete = false;
          } else {
            isProfileComplete = false;
          }

          debugPrint('🔍 isProfileComplete: $isProfileComplete');

          await Future.delayed(const Duration(seconds: 2));

          if (!mounted) return;

          if (isProfileComplete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationLayout(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CompleteProfileScreen(),
              ),
            );
          }
          return;
        } catch (e) {
          debugPrint('🔍 Error loading profile: $e');
          // If profile loading fails, go to complete profile screen
        }
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _handelThemeMode() async {
    try {
      final themeMode = await getThemeMode();
      setThemeMode(ref, themeMode);
    } catch (e) {
      debugPrint('🔥 Error getting theme mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Removed dead `isDark` branch — both branches used the same color.
    // Now using colorScheme.primary directly, which already respects the theme.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Image.asset(AssetsUtils.emojiWink, width: 56, height: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mini Reddit',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The front page of your feed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
