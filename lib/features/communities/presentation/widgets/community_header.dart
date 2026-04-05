import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/widgets/edit_community.dart';

class CommunityHeader extends ConsumerWidget {
  final CommunityDetailsModel details;

  const CommunityHeader({super.key, required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = details.community;
    if (community == null) return const SizedBox.shrink();

    return Container(
      color: context.tokens.bgSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommunityBanner(community: community),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarAndActionsRow(
                  details: details,
                  community: community,
                  isModerator: details.userStatus.isAdmin,
                ),
                const SizedBox(height: AppSpacing.sm),
                _CommunityTitleSection(community: community),
                const SizedBox(height: AppSpacing.xs),
                _CommunityStats(details: details),
                if (community.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.md),
                  _CommunityDescription(community: community),
                ],
                const SizedBox(height: AppSpacing.md),
                _CommunityTags(community: community),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner ──────────────────────────────────────────────────
class _CommunityBanner extends StatelessWidget {
  final CommunityModel community;

  const _CommunityBanner({required this.community});

  @override
  Widget build(BuildContext context) {
    final hasBanner = community.bannerUrl != null;
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.tokens.brandOrange.withOpacity(0.85),
        image: hasBanner
            ? DecorationImage(
                image: NetworkImage(community.bannerUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasBanner
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.tokens.brandOrangeDark,
                    context.tokens.brandOrange,
                    context.tokens.brandOrangeLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
    );
  }
}

// ─── Avatar + Action Row ─────────────────────────────────────
class _AvatarAndActionsRow extends ConsumerWidget {
  final CommunityDetailsModel details;
  final CommunityModel community;
  final bool isModerator;

  const _AvatarAndActionsRow({
    required this.details,
    required this.community,
    required this.isModerator,
  });

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditCommunitySheet(community: community),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joined = details.userStatus.isMember;
    final tokens = context.tokens;

    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar — pops above the banner
          Positioned(
            top: -38,
            left: 0,
            child: _CommunityAvatar(community: community, tokens: tokens),
          ),

          // Actions aligned to the right
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isModerator) ...[
                  _ModeratorBadge(tokens: tokens),
                  const SizedBox(width: AppSpacing.sm),
                  _EditButton(
                    tokens: tokens,
                    onTap: () => _openEditSheet(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                const SizedBox(width: AppSpacing.sm),
                _JoinButton(
                  joined: joined,
                  tokens: tokens,
                  onPressed: () {
                    if (joined) {
                      ref
                          .read(communitiesActionsProvider.notifier)
                          .leaveCommunity(community.id);
                    } else {
                      ref
                          .read(communitiesActionsProvider.notifier)
                          .joinCommunity(community.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityAvatar extends StatelessWidget {
  final CommunityModel community;
  final RedditTokens tokens;

  const _CommunityAvatar({required this.community, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tokens.bgSurface, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: tokens.brandOrange,
        backgroundImage: community.imageUrl != null
            ? NetworkImage(community.imageUrl!)
            : null,
        child: community.imageUrl == null
            ? Text(
                community.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

class _ModeratorBadge extends StatelessWidget {
  final RedditTokens tokens;

  const _ModeratorBadge({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: tokens.brandOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: tokens.brandOrange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 12, color: tokens.brandOrange),
          const SizedBox(width: 4),
          Text(
            'MOD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: tokens.brandOrange,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final RedditTokens tokens;
  final VoidCallback onTap;

  const _EditButton({required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.borderDefault),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: tokens.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Edit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final bool joined;
  final RedditTokens tokens;
  final VoidCallback onPressed;

  const _JoinButton({
    required this.joined,
    required this.tokens,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (joined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.borderDefault),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: tokens.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Joined',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.brandOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Join',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

// ─── Title & Name ────────────────────────────────────────────
class _CommunityTitleSection extends StatelessWidget {
  final CommunityModel community;

  const _CommunityTitleSection({required this.community});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          community.name,
          style: context.rTypo.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'r/${community.name}',
          style: context.rTypo.bodySmall.copyWith(
            color: context.tokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Stats ───────────────────────────────────────────────────
class _CommunityStats extends StatelessWidget {
  final CommunityDetailsModel details;

  const _CommunityStats({required this.details});

  @override
  Widget build(BuildContext context) {
    final stats = details.stats;
    final tokens = context.tokens;
    return _StatChip(
      count: TimeFormatter.formatNumber(stats.membersCount),
      label: 'Members',
      tokens: tokens,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String count;
  final String label;
  final RedditTokens tokens;

  const _StatChip({
    required this.count,
    required this.label,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: tokens.textPrimary,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Description ─────────────────────────────────────────────
class _CommunityDescription extends StatefulWidget {
  final CommunityModel community;

  const _CommunityDescription({required this.community});

  @override
  State<_CommunityDescription> createState() => _CommunityDescriptionState();
}

class _CommunityDescriptionState extends State<_CommunityDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final description = widget.community.description!;
    final isLong = description.length > 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            description,
            style: context.rTypo.bodyMedium.copyWith(
              color: tokens.textPrimary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            description,
            style: context.rTypo.bodyMedium.copyWith(
              color: tokens.textPrimary,
              height: 1.5,
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (isLong) ...[
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Show more',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tokens.brandBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Tags / Flair ────────────────────────────────────────────
class _CommunityTags extends StatelessWidget {
  final CommunityModel community;

  const _CommunityTags({required this.community});

  @override
  Widget build(BuildContext context) {
    // Show community type tags
    final tags = <String>[];
    // TODO: Add tags when supported by our community model (e.g. NSFW, Public/Private)

    if (tags.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;
    return Wrap(
      spacing: AppSpacing.sm,
      children: tags.map((tag) {
        final isNsfw = tag == 'NSFW';
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs + 1,
          ),
          decoration: BoxDecoration(
            color: isNsfw ? tokens.error.withOpacity(0.12) : tokens.bgElevated,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isNsfw
                  ? tokens.error.withOpacity(0.3)
                  : tokens.borderDefault,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isNsfw ? tokens.error : tokens.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        );
      }).toList(),
    );
  }
}
