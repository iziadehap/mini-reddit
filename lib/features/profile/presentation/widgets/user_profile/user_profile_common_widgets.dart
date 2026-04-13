import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class ProfileCircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProfileCircleActionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return IconButton(
      onPressed: onTap,
      icon: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tokens.bgOverlay,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: tokens.textPrimary, size: 22),
      ),
    );
  }
}

class ProfileAvatarView extends StatelessWidget {
  final String initials;
  final String? avatarUrl;

  const ProfileAvatarView({
    super.key,
    required this.initials,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasAvatar = (avatarUrl ?? '').trim().isNotEmpty;

    return Container(
      width: 94,
      height: 94,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tokens.bgSurface, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: tokens.bgElevated,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
        child: hasAvatar
            ? null
            : Text(
                initials,
                style: context.rTypo.titleLarge.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class ProfileStatCell extends StatelessWidget {
  final String value;
  final String label;
  final Widget? leading;

  const ProfileStatCell({
    super.key,
    required this.value,
    required this.label,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(height: 2),
        ] else
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        Text(
          label,
          style: typo.bodySmall.copyWith(color: tokens.textSecondary),
        ),
      ],
    );
  }
}

class ProfileAboutTile extends StatelessWidget {
  final String title;
  final String value;

  const ProfileAboutTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tokens.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typo.bodySmall.copyWith(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: typo.bodyMedium.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
