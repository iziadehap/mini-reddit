import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/community_details_provider.dart';

class EditCommunityAdminSheet extends ConsumerStatefulWidget {
  final CommunityModel community;

  const EditCommunityAdminSheet({super.key, required this.community});

  @override
  ConsumerState<EditCommunityAdminSheet> createState() =>
      _EditCommunityAdminSheetState();
}

class _EditCommunityAdminSheetState
    extends ConsumerState<EditCommunityAdminSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _bannerUrlController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community.name);
    _imageUrlController = TextEditingController(
      text: widget.community.imageUrl ?? '',
    );
    _bannerUrlController = TextEditingController(
      text: widget.community.bannerUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Community name must be at least 3 characters');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    await ref
        .read(communityDetailsProvider.notifier)
        .editCommunity(
          communityId: widget.community.id,
          name: name,
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          bannerUrl: _bannerUrlController.text.trim().isEmpty
              ? null
              : _bannerUrlController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    final state = ref.read(communityDetailsProvider);
    final hasError = state.hasError;
    if (hasError) {
      setState(() {
        _isSaving = false;
        _error = state.error.toString();
      });
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Community', style: typo.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Admins can update community name, profile photo, and cover photo.',
              style: typo.bodySmall.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _field(_nameController, 'Community name (r/...)', tokens),
            const SizedBox(height: AppSpacing.md),
            _field(_imageUrlController, 'Community profile image URL', tokens),
            const SizedBox(height: AppSpacing.md),
            _field(_bannerUrlController, 'Community cover image URL', tokens),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: typo.bodySmall.copyWith(color: tokens.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.brandOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    RedditTokens tokens,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: tokens.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
