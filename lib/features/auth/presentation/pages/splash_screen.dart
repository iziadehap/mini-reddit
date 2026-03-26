import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/widgets/main_navigation_layout.dart';
import 'package:mini_reddit_v2/features/auth/presentation/pages/login_screen.dart';
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
    final isAlreadyLoggedIn =
        await ref.read(authProvider.notifier).isAlreadyLoggedIn();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await ref.read(profileProvider(userId).notifier).getProfile();
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isAlreadyLoggedIn
            ? const MainNavigationLayout()
            : const LoginScreen(),
      ),
    );
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.reddit,
                size: 56,
                color: Colors.white,
              ),
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
                color: Colors.white.withOpacity(0.65),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}