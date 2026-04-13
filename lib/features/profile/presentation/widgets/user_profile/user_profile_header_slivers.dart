import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_active_in.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_common_widgets.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_formatters.dart';

List<Widget> buildUserProfileHeaderSlivers({
  required BuildContext context,
  required UserProfileModel profile,
  required bool blocked,
  required bool showSearch,
  required bool isOwnProfile,
  required bool isFollowing,
  required int followersCount,
  required int contributions,
  required String searchQuery,
  required List<ActiveCommunity> activeCommunities,
  required TabController tabController,
  required VoidCallback onBack,
  required VoidCallback onToggleSearch,
  required VoidCallback onShare,
  required VoidCallback onBlock,
  required VoidCallback onFollow,
  required ValueChanged<String> onSearchChanged,
  required VoidCallback onActiveInTap,
}) {
  final tokens = context.tokens;
  final typo = context.rTypo;

  return [
    SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: tokens.bgSurface,
      automaticallyImplyLeading: false,
      leading: ProfileCircleActionButton(icon: Icons.arrow_back, onTap: onBack),
      actions: [
        ProfileCircleActionButton(icon: Icons.search, onTap: onToggleSearch),
        ProfileCircleActionButton(icon: Icons.ios_share, onTap: onShare),
        PopupMenuButton<String>(
          color: tokens.bgSurface,
          onSelected: (value) {
            if (value == 'block') onBlock();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'block',
              child: Text(blocked ? 'Unblock user' : 'Block user'),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            _cover(profile.bannerUrl, tokens),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    tokens.bgPage.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              bottom: AppSpacing.xl,
              child: ProfileAvatarView(
                initials: profile.initials,
                avatarUrl: profile.avatarUrl,
              ),
            ),
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Container(
        color: tokens.bgSurface,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.displayName,
                    style: typo.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isOwnProfile && !blocked)
                  ElevatedButton(
                    onPressed: onFollow,
                    child: Text(isFollowing ? 'Following' : 'Follow'),
                  ),
              ],
            ),
            Text(
              'u/${profile.username}',
              style: typo.bodyMedium.copyWith(color: tokens.textSecondary),
            ),
            Text(
              '${formatProfileCount(followersCount)} followers · ${formatProfileCount(profile.followingCount)} following',
              style: typo.bodyMedium.copyWith(color: tokens.textSecondary),
            ),
            if (activeCommunities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ActiveInSummaryRow(communities: activeCommunities),
            ],
            if ((profile.bio ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(profile.bio!, style: typo.bodyLarge),
            ],
            const SizedBox(height: AppSpacing.md),
            Divider(color: tokens.divider),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ProfileStatCell(
                    value: formatProfileCount(profile.karma),
                    label: 'Karma',
                  ),
                ),
                _v(tokens),
                Expanded(
                  child: ProfileStatCell(
                    value: formatProfileCount(contributions),
                    label: 'Contributions',
                  ),
                ),
                _v(tokens),
                Expanded(
                  child: ProfileStatCell(
                    value: accountAgeLabel(profile.createdAt),
                    label: 'Account Age',
                  ),
                ),
                _v(tokens),
                Expanded(
                  child: ActiveInStatCell(
                    communities: activeCommunities,
                    onTap: onActiveInTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    if (showSearch)
      SliverToBoxAdapter(
        child: Container(
          color: tokens.bgSurface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            onChanged: onSearchChanged,
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.collapsed(offset: searchQuery.length),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search posts and comments',
            ),
          ),
        ),
      ),
    SliverPersistentHeader(
      pinned: true,
      delegate: _TabHeaderDelegate(
        color: tokens.bgSurface,
        tabBar: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Comments'),
            Tab(text: 'About'),
          ],
        ),
      ),
    ),
  ];
}

Widget _cover(String? bannerUrl, RedditTokens tokens) {
  final has = (bannerUrl ?? '').trim().isNotEmpty;
  if (has) {
    return Image.network(
      bannerUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _coverFallback(tokens),
    );
  }
  return _coverFallback(tokens);
}

Widget _coverFallback(RedditTokens tokens) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [tokens.bgElevated, tokens.bgCanvas]),
    ),
  );
}

Widget _v(RedditTokens tokens) {
  return Container(
    width: 1,
    height: 46,
    color: tokens.divider,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
  );
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;
  const _TabHeaderDelegate({required this.tabBar, required this.color});
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: color, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar || oldDelegate.color != color;
  }
}
