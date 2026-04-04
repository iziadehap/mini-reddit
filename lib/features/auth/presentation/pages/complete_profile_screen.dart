import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';
import 'package:mini_reddit_v2/core/utils/image_utils.dart';
import 'package:mini_reddit_v2/core/widgets/main_navigation_layout.dart';
import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_provider.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _imageFile;

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImageUtils.pickAndCompressImage();
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _saveProfile() async {
    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await ref.read(authProvider.notifier).uploadImage(_imageFile!);
      if (imageUrl == null) return; // Error handled by notifier
    }

    await ref
        .read(authProvider.notifier)
        .completeProfile(
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
          username: _usernameController.text.trim(),
          avatarUrl: imageUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(authProvider, (previous, next) {
      if (!context.mounted) return;

      // ✅ FIX: Navigate to main app once profile is completed.
      // Previously there was no navigation here at all — completing the profile
      // would silently succeed but the user would remain stuck on this screen.
      if (next.isCompleteProfile && !(previous?.isCompleteProfile ?? false)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationLayout()),
          (route) => false,
        );
        return;
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
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
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complete Profile',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AssetsUtils.emojiHappy, width: 24, height: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Tell us about yourself',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'You can always change this later',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // ── Avatar Picker ──────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.onSurface.withOpacity(0.08),
                            border: Border.all(
                              color: _imageFile != null
                                  ? const Color(0xFFFF4500)
                                  : colorScheme.onSurface.withOpacity(0.15),
                              width: 2,
                            ),
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageFile == null
                              ? Icon(
                                  Icons.person_outline_rounded,
                                  size: 48,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4500),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap to add photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Username ───────────────────────────────────────────────
                _InputLabel(label: 'Username'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration(
                    context,
                    hint: 'e.g. cool_redditor',
                    icon: Icons.alternate_email_rounded,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Full Name ──────────────────────────────────────────────
                _InputLabel(label: 'Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  decoration: _inputDecoration(
                    context,
                    hint: 'Your display name',
                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Bio ────────────────────────────────────────────────────
                _InputLabel(label: 'Bio'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    context,
                    hint: 'Tell others a bit about yourself…',
                    icon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Save Button ────────────────────────────────────────────
                FilledButton(
                  onPressed: authState.isLoading ? null : _saveProfile,
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
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
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
