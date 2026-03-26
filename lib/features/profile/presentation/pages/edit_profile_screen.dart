// lib/features/profile/presentation/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _aboutController;
  File? _selectedAvatarImage;
  File? _selectedBannerImage;
  bool _isLoading = false;
  final List<Map<String, String>> _socialLinks = [];

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.profile.fullName,
    );
    _aboutController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null)
      setState(() => _selectedAvatarImage = File(picked.path));
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null)
      setState(() => _selectedBannerImage = File(picked.path));
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await ref
          .read(profileProvider(widget.profile.id).notifier)
          .updateProfile(
            fullName: _displayNameController.text,
            bio: _aboutController.text,
            avatar: _selectedAvatarImage,
          );
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // ── Banner + Avatar overlap (using Stack so avatar is never clipped) ──
            // avatarRadius=44, border=3 → total avatar height = (44+3)*2 = 94px
            // We want half (47px) to hang below the banner, so banner container
            // height is 120, and the Stack's total height is 120 + 47 = 167.
            SizedBox(
              height: 167,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: GestureDetector(
                      onTap: _pickBannerImage,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _selectedBannerImage != null
                                ? Image.file(
                                    _selectedBannerImage!,
                                    fit: BoxFit.cover,
                                  )
                                : (widget.profile.bannerUrl != null
                                      ? Image.network(
                                          widget.profile.bannerUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _defaultBanner(context),
                                        )
                                      : _defaultBanner(context)),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.28),
                              child: const Center(
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Avatar — centered vertically on the banner bottom edge
                  // top = 120 - 47 = 73  (half of avatar pokes above, half below)
                  Positioned(
                    top: 73,
                    left: 16,
                    child: GestureDetector(
                      onTap: _pickAvatarImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.outline,
                              backgroundImage: _selectedAvatarImage != null
                                  ? FileImage(_selectedAvatarImage!)
                                        as ImageProvider
                                  : (widget.profile.avatarUrl != null
                                        ? NetworkImage(
                                            widget.profile.avatarUrl!,
                                          )
                                        : null),
                              child:
                                  _selectedAvatarImage == null &&
                                      widget.profile.avatarUrl == null
                                  ? Text(
                                      widget.profile.initials,
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          // Camera badge
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Read-only stats ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(context, _fmt(widget.profile.karma), 'Karma'),
                        _vDivider(context),
                        _stat(
                          context,
                          _fmt(widget.profile.followersCount),
                          'Followers',
                        ),
                        _vDivider(context),
                        _stat(
                          context,
                          _fmt(widget.profile.followingCount),
                          'Following',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Display Name ──────────────────────────────────────
                  _Label(label: 'Display name', suffix: 'optional'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: _dec(context, hint: 'Add a display name'),
                  ),
                  const SizedBox(height: 6),
                  _hint(
                    context,
                    'Shown on your profile page. Does not change your username.',
                  ),

                  const SizedBox(height: 24),

                  // ── About ─────────────────────────────────────────────
                  _Label(label: 'About you', suffix: 'optional'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: _dec(context, hint: 'Tell us about yourself'),
                  ),

                  const SizedBox(height: 24),

                  // ── Social Links ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Label(label: 'Social Links', suffix: '5 max'),
                      Text(
                        '${_socialLinks.length}/5',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _hint(
                    context,
                    'Visible to people who visit your Reddit profile.',
                  ),
                  const SizedBox(height: 12),

                  ..._socialLinks.map(
                    (link) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              child: Text(
                                link['platform']!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () =>
                                setState(() => _socialLinks.remove(link)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: _socialLinks.length < 5 ? () {} : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Add social link'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────

  Widget _defaultBanner(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: Theme.of(context).brightness == Brightness.dark
            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
            : [const Color(0xFFCFD8DC), const Color(0xFFB0BEC5)],
      ),
    ),
  );

  Widget _stat(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _vDivider(BuildContext context) => Container(
    height: 28,
    width: 1,
    color: Theme.of(context).colorScheme.outline,
  );

  Widget _hint(BuildContext context, String text) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );

  InputDecoration _dec(BuildContext context, {required String hint}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  String _fmt(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

// ─────────────────────────────────────────
// Shared label widget
// ─────────────────────────────────────────
class _Label extends StatelessWidget {
  final String label;
  final String? suffix;
  const _Label({required this.label, this.suffix});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        if (suffix != null) ...[
          const SizedBox(width: 6),
          Text(
            '– $suffix',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
