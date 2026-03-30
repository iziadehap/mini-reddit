import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/custom_snackbar.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/community_details_provider.dart';

class EditCommunitySheet extends ConsumerStatefulWidget {
  final CommunityModel community;

  const EditCommunitySheet({super.key, required this.community});

  @override
  ConsumerState<EditCommunitySheet> createState() => _EditCommunitySheetState();
}

class _EditCommunitySheetState extends ConsumerState<EditCommunitySheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _bannerUrlController;
  late final TextEditingController _imageUrlController;
  late bool _isPublic;
  late bool _isNSFW;

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.community;
    _nameController = TextEditingController(text: c.name);
    _descriptionController = TextEditingController(text: c.description ?? '');
    _bannerUrlController = TextEditingController(text: c.bannerUrl ?? '');
    _imageUrlController = TextEditingController(text: c.imageUrl ?? '');
    // _isPublic = c.isPublic ?? true;
    // _isNSFW = c.isNSFW ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bannerUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Community name cannot be empty.');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref
          .read(communityDetailsProvider.notifier)
          .editCommunity(
            communityId: widget.community.id,
            name: name,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            bannerUrl: _bannerUrlController.text.trim().isEmpty
                ? null
                : _bannerUrlController.text.trim(),
            imageUrl: _imageUrlController.text.trim().isEmpty
                ? null
                : _imageUrlController.text.trim(),
            isPublic: _isPublic,
            isNSFW: _isNSFW,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    ref.listen(SuccessEditCommunityProvider, (previous, next) {
      if (next != null) {
        showCustomSnackBar(
          context,
          isError: next.isError,
          isDark: tokens.isDark,
          message: next.message,
          color: next.isError ? Colors.red : Colors.green,
          icon: next.isError ? Icons.error_outline : Icons.check_circle_outline,
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderDefault,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header
            Row(
              children: [
                Icon(Icons.edit_outlined, size: 20, color: tokens.brandOrange),
                const SizedBox(width: AppSpacing.sm),
                Text('Edit Community', style: context.rTypo.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: tokens.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Divider(color: tokens.divider, height: 1),
            const SizedBox(height: AppSpacing.lg),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _SectionLabel(label: 'Community Name', tokens: tokens),
                    const SizedBox(height: AppSpacing.sm),
                    _StyledTextField(
                      controller: _nameController,
                      hint: 'e.g. flutter, programming',
                      prefixText: 'r/',
                      tokens: tokens,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _SectionLabel(label: 'Description', tokens: tokens),
                    const SizedBox(height: AppSpacing.sm),
                    _StyledTextField(
                      controller: _descriptionController,
                      hint: 'What is your community about?',
                      maxLines: 4,
                      tokens: tokens,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Banner URL
                    _SectionLabel(label: 'Banner Image URL', tokens: tokens),
                    const SizedBox(height: AppSpacing.sm),
                    _StyledTextField(
                      controller: _bannerUrlController,
                      hint: 'https://example.com/banner.jpg',
                      tokens: tokens,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Avatar / Icon URL
                    _SectionLabel(label: 'Community Icon URL', tokens: tokens),
                    const SizedBox(height: AppSpacing.sm),
                    _StyledTextField(
                      controller: _imageUrlController,
                      hint: 'https://example.com/icon.jpg',
                      tokens: tokens,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    Divider(color: tokens.divider, height: 1),
                    const SizedBox(height: AppSpacing.md),

                    // Community Type
                    _SectionLabel(label: 'Community Type', tokens: tokens),
                    const SizedBox(height: AppSpacing.sm),
                    _ToggleRow(
                      icon: Icons.public_outlined,
                      title: 'Public',
                      subtitle: 'Anyone can view, post, and comment',
                      value: _isPublic,
                      tokens: tokens,
                      onChanged: (v) => setState(() => _isPublic = v),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // NSFW
                    _SectionLabel(label: 'Content Rating', tokens: tokens),
                    const SizedBox(height: AppSpacing.sm),
                    _ToggleRow(
                      icon: Icons.warning_amber_outlined,
                      title: 'NSFW',
                      subtitle: 'Mark community as 18+ content',
                      value: _isNSFW,
                      tokens: tokens,
                      activeColor: tokens.error,
                      onChanged: (v) => setState(() => _isNSFW = v),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: tokens.error.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: tokens.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: tokens.error,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tokens.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final RedditTokens tokens;

  const _SectionLabel({required this.label, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: tokens.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? prefixText;
  final RedditTokens tokens;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.tokens,
    this.maxLines = 1,
    this.prefixText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: tokens.textPrimary,
        fontFamily: 'IBMPlexSans',
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: 14,
          color: tokens.textSecondary,
          fontFamily: 'IBMPlexSans',
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: tokens.bgInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(color: tokens.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: tokens.brandOrange, width: 1.5),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final RedditTokens tokens;
  final Color? activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.tokens,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? tokens.brandOrange;
    return Container(
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.07) : tokens.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: value ? color.withOpacity(0.3) : tokens.borderDefault,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value ? color.withOpacity(0.12) : tokens.bgSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: value ? color : tokens.textSecondary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: tokens.textSecondary),
        ),
      ),
    );
  }
}
