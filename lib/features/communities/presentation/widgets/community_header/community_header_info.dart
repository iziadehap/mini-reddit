part of '../community_header.dart';

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

class _CommunityTags extends StatelessWidget {
  final CommunityModel community;

  const _CommunityTags({required this.community});

  @override
  Widget build(BuildContext context) {
    final tags = <String>[];
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
