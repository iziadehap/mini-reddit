import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';

class ProfileCommentTile extends StatelessWidget {
  final UserProfileCommentItem item;
  final VoidCallback onTap;

  const ProfileCommentTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return Material(
      color: tokens.cardBg,
      child: InkWell(
        onTap: onTap,
        highlightColor: tokens.brandOrange.withOpacity(0.05),
        splashColor: tokens.brandOrange.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: tokens.divider, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.communityName.isNotEmpty
                    ? 'r/${item.communityName} · ${item.postTitle}'
                    : item.postTitle,
                style: typo.postMeta.copyWith(color: tokens.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.content,
                style: typo.bodyMedium.copyWith(color: tokens.textPrimary),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 16,
                    color: tokens.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    TimeFormatter.formatNumber(item.score),
                    style: typo.voteCount,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('·', style: typo.postMeta),
                  ),
                  Text(
                    TimeFormatter.getTimeAgo(item.createdAt),
                    style: typo.postMeta,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
