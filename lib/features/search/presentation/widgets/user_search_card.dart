import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class UserSearchCard extends ConsumerWidget {
  final UserProfileModel user;
  const UserSearchCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final typography = context.rTypo;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/profile',
          arguments: user.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: tokens.borderDefault,
                  width: 0.8,
                ),
              ),
              child: ClipOval(
                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 24,
                            color: tokens.textMuted,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 24,
                            color: tokens.textMuted,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          user.fullName != null && user.fullName!.isNotEmpty
                              ? user.fullName![0].toUpperCase()
                              : user.initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'u/${user.username}',
                    style: typography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.fullName ?? '',
                    style: typography.bodySmall.copyWith(
                      color: tokens.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.stars_outlined,
                        size: 14,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.karma} karma',
                        style: typography.labelSmall.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
