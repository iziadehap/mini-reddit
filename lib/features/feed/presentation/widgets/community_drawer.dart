// lib/features/feed/presentation/widgets/community_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/feed_type.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/create_community.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/communities_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_state.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/user_communities_provider.dart';

class CommunityDrawer extends ConsumerStatefulWidget {
  const CommunityDrawer({super.key});

  @override
  ConsumerState<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends ConsumerState<CommunityDrawer> {
  bool _isCommunitiesExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userCommunitiesProvider.notifier).fetchUserCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final userCommunitiesAsync = ref.watch(userCommunitiesProvider);

    return Drawer(
      backgroundColor: context.tokens.bgPage,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header with User Info
            // _buildDrawerHeader(context),

            // Feed Filters Section
            _buildFeedFilters(feedState),
            const SizedBox(height: 20),

            const Divider(height: 1, thickness: 1),

            // Communities Section Header with Toggle
            _buildCommunitiesHeader(),

            // Communities List (Expandable)
            if (_isCommunitiesExpanded)
              _buildCommunitiesList(userCommunitiesAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedFilters(FeedState feedState) {
    return Column(
      children: [
        // Feed Type Items
        ...List.generate(FeedTypeUtils.feedType.length, (index) {
          final typeName = FeedTypeUtils.feedType[index];
          final type = FeedTypeUtils.getTypeForIndex(typeName);
          final isSelected = feedState.feedType == type;

          return _buildFeedFilterItem(
            icon: FeedTypeUtils.feedTypeIcon[index],
            title: typeName,
            isSelected: isSelected,
            trailing: type == FeedType.top
                ? _buildTimeframeSelector(feedState)
                : null,
            onTap: () {
              // check if screen now = communities_screen , pop to feed screen
              // if (ModalRoute.of(context)?.settings.name == CommunitiesScreen) {
              //   Navigator.pop(context);
              // }
              ref.read(feedProvider.notifier).setFeedType(type);
              Navigator.pop(context);
            },
          );
        }),
      ],
    );
  }

  Widget _buildFeedFilterItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required Widget? trailing,
    required VoidCallback onTap,
  }) {
    final tokens = context.tokens;
    final rTypo = context.rTypo;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        color: isSelected ? tokens.bgElevated : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? tokens.brandOrange : tokens.textSecondary,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: isSelected
                    ? rTypo.labelLarge.copyWith(color: tokens.brandOrange)
                    : rTypo.bodyMedium.copyWith(color: tokens.textPrimary),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector(FeedState feedState) {
    final tokens = context.tokens;
    return GestureDetector(
      onTap: () => _showTimeframeBottomSheet(feedState),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: tokens.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FeedTypeUtils.getLabelForTimeframe(feedState.timeframe),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tokens.brandOrange,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: tokens.brandOrange),
          ],
        ),
      ),
    );
  }

  void _showTimeframeBottomSheet(FeedState feedState) {
    final tokens = context.tokens;

    if (feedState.feedType == FeedType.top) {
      showModalBottomSheet(
        context: context,
        backgroundColor: tokens.bgSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text('Sort by time', style: context.rTypo.titleMedium),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...TopFeedTimeframe.values.map((tf) {
                  final isSelected = tf == feedState.timeframe;
                  return ListTile(
                    title: Text(
                      FeedTypeUtils.getLabelForTimeframe(tf),
                      style: context.rTypo.bodyLarge.copyWith(
                        color: isSelected
                            ? tokens.brandOrange
                            : tokens.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: tokens.brandOrange)
                        : null,
                    onTap: () {
                      ref.read(feedProvider.notifier).setTimeframe(tf);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildCommunitiesHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isCommunitiesExpanded = !_isCommunitiesExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              _isCommunitiesExpanded ? Icons.group : Icons.group_outlined,
              size: 20,
              color: context.tokens.textPrimary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Your Communities',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            // Create Community Button (Quick action)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                size: 22,
                color: context.tokens.brandOrange,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCommunityScreen(),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Icon(
              _isCommunitiesExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: context.tokens.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesList(
    AsyncValue<List<UserCommunityModel>> communitiesAsync,
    // FeedState feedState,
  ) {
    return communitiesAsync.maybeWhen(
      loading: () => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.tokens.brandOrange,
            ),
          ),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),

      data: (communities) {
        debugPrint("communities: ${communities.length}");
        // final communities = communitiesAsync.value ?? [];
        if (communities.isEmpty) {
          return _buildEmptyCommunities();
        }

        return Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: communities.length + 1, // +1 for "Browse all"
            itemBuilder: (context, index) {
              if (index == communities.length) {
                return _buildBrowseAllItem();
              }

              final community = communities[index];
              return _buildCommunityTile(community);
            },
          ),
        );
      },
      orElse: () {
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCommunityTile(dynamic community) {
    final tokens = context.tokens;
    final rTypo = context.rTypo;

    return InkWell(
      onTap: () {
        // ref.read(feedProvider.notifier).selectCommunity(community.name);

        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityScreen(communityId: community.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Community Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.bgElevated,
                border: Border.all(color: tokens.borderDefault, width: 0.5),
              ),
              child: ClipOval(
                child: community.imageUrl != null
                    ? Image.network(
                        community.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarFallback(community),
                      )
                    : _buildAvatarFallback(community),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Community Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('r/${community.name}', style: rTypo.communityName),
                  const SizedBox(height: 1),
                  Text(
                    '${community.membersCount} members',
                    style: rTypo.bodySmall.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Member Indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: tokens.brandOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'Joined',
                style: rTypo.labelSmall.copyWith(
                  color: tokens.brandOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic community) {
    return Center(
      child: Text(
        community.name[0].toUpperCase(),
        style: context.rTypo.labelMedium.copyWith(
          color: context.tokens.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBrowseAllItem() {
    final tokens = context.tokens;
    final rTypo = context.rTypo;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommunitiesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.brandOrange.withOpacity(0.1),
              ),
              child: Icon(Icons.explore, size: 18, color: tokens.brandOrange),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('Browse all communities', style: rTypo.bodyMedium),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: tokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCommunities() {
    final tokens = context.tokens;
    final rTypo = context.rTypo;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.bgElevated,
            ),
            child: Icon(Icons.group_off, size: 40, color: tokens.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No communities yet', style: rTypo.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Join communities to see them here',
            style: rTypo.bodySmall.copyWith(color: tokens.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunitiesScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.brandOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            child: const Text('Browse Communities'),
          ),
        ],
      ),
    );
  }
}
