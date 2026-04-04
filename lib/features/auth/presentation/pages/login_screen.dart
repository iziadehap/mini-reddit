import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';
import 'package:mini_reddit_v2/core/widgets/main_navigation_layout.dart';
import 'package:mini_reddit_v2/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_provider.dart';

import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    ref
        .read(authProvider.notifier)
        .signIn(_emailController.text.trim(), _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ✅ FIX: Use `next` (not `authState`) for all navigation decisions inside the listener.
    // Using `authState` here was the root cause — it's a stale snapshot from the last build,
    // so conditions like `authState.userProfileModel != null` would never fire correctly
    // on the exact frame the state changed.
    ref.listen(authProvider, (previous, next) {
      if (!context.mounted) return;

      // Show errors — but skip the "Profile not found" sentinel which drives navigation below
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          next.errorMessage != 'Profile not found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return; // Don't fall through to navigation checks
      }

      // ✅ FIX: Check `next.isSignInSuccess` combined with `next.userProfileModel`
      // instead of the stale `authState.userProfileModel`.
      if (next.isSignInSuccess && next.userProfileModel != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationLayout()),
        );
        return;
      }

      // ✅ FIX: "Profile not found" means user authenticated but has no profile yet.
      // Previously this was inside the same else-if chain as the error check above,
      // so it was unreachable when errorMessage was set. Now it's a separate check on `next`.
      if (next.errorMessage == 'Profile not found') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CompleteProfileScreen(),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // ── Logo ──────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4500),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4500).withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.reddit,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AssetsUtils.emojiWink, width: 28, height: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Welcome back',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Sign in to continue to Mini Reddit',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Email ─────────────────────────────────────────────────
                _InputLabel(label: 'Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    context,
                    hint: 'you@example.com',
                    icon: Icons.alternate_email_rounded,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Password ──────────────────────────────────────────────
                _InputLabel(label: 'Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    context,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Sign In Button ─────────────────────────────────────────
                FilledButton(
                  onPressed: authState.isLoading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4500),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // ── Divider ────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Google Button ──────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : () {},
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Sign Up Link ───────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          ),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.55),
                          fontSize: 14,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Color(0xFFFF4500),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        letterSpacing: 0.3,
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
    prefixIcon: Icon(
      icon,
      size: 20,
      color: colorScheme.onSurface.withOpacity(0.45),
    ),
    suffixIcon: suffix,
    filled: true,
    fillColor: colorScheme.onSurface.withOpacity(0.05),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF4500), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error),
    ),
  );
}
