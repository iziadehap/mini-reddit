// lib/features/profile/presentation/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme.dart';
import 'package:mini_reddit_v2/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:mini_reddit_v2/features/profile/presentation/pages/setting_screen.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // The banner height that is always visible (avatar sits on this bottom edge)
  static const double _bannerHeight = 220.0;
  // avatar radius + white border
  static const double _avatarRadius = 44.0;
  static const double _avatarBorder = 3.0;
  static const double _avatarTotal =
      _avatarRadius + _avatarBorder - 20; // 47px half-height

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        ref.read(profileProvider(userId).notifier).getProfile();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(myProfileProvider);

    return Scaffold(
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (profile) => _buildProfileContent(context, profile),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileModel profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // ─────────────────────────────────────────────────────────────────
          // SliverAppBar: full-bleed banner image, avatar pinned to its bottom
          // ─────────────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _bannerHeight,
            pinned: true,
            floating: false,
            // Make the collapsed bar transparent so the banner bleeds through
            backgroundColor: Theme.of(context).colorScheme.surface,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            // No leading — Reddit style has username pill top-left (omitted here)
            automaticallyImplyLeading: false,
            actions: [
              _iconBtn(Icons.search, () {}),
              _iconBtn(Icons.ios_share_outlined, () {}),
              _iconBtn(
                Icons.more_horiz,
                () => _showOptionsSheet(context, profile),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              // The background is the banner + avatar stacked
              background: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Full-bleed banner ──────────────────────────────────
                  Positioned.fill(
                    child: profile.bannerUrl != null
                        ? Image.network(
                            profile.bannerUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultBanner(),
                          )
                        : _defaultBanner(),
                  ),

                  // Dark gradient at the bottom of the banner so avatar
                  // border blends nicely (like Reddit does)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Avatar — centered on the banner's bottom edge ──────
                  // bottom = -_avatarTotal so exactly half hangs below
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: _buildAvatar(profile),
                  ),
                ],
              ),
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // Info block: name, username, followers, stats
          // ─────────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacer to clear the avatar overhang
                  SizedBox(height: _avatarTotal + 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name row + Edit button ─────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                profile.displayName,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      letterSpacing: -0.3,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Edit button — plain text like Reddit
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfileScreen(profile: profile),
                                ),
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ── u/username · X followers ──────────────────
                        Row(
                          children: [
                            Text(
                              'u/${profile.username}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    '${_formatCount(profile.followersCount)} followers',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Bio (if set)
                        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            profile.bio!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Stats row with vertical dividers ──────────
                        _buildStatsRow(context, profile),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // Sticky TabBar
          // ─────────────────────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              tabBar: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                indicatorColor: Theme.of(context).colorScheme.onSurface,
                indicatorWeight: 2.5,
                dividerColor: Theme.of(context).colorScheme.onSurface,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Comments'),
                  Tab(text: 'About'),
                ],
              ),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ];
      },

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(context),
          _buildCommentsTab(context),
          _buildAboutTab(context, profile),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Widgets
  // ───────────────────────────────────────────────────────────────────────────

  Widget _defaultBanner() => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.onSurface,
          Theme.of(context).colorScheme.onSurface,
        ],
      ),
    ),
  );

  /// Avatar with white border ring — exactly like Reddit
  Widget _buildAvatar(UserProfileModel profile) {
    return Container(
      width: (_avatarRadius + _avatarBorder) * 2,
      height: (_avatarRadius + _avatarBorder) * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // white ring
      ),
      padding: const EdgeInsets.all(_avatarBorder),
      child: CircleAvatar(
        radius: _avatarRadius,
        backgroundColor: const Color(0xFF818384),
        backgroundImage: profile.avatarUrl != null
            ? NetworkImage(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? Text(
                profile.initials,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  /// Stats row: Karma | Contributions | Account Age | Active In
  Widget _buildStatsRow(BuildContext context, UserProfileModel profile) {
    final dividerColor = Theme.of(context).colorScheme.onSurface;

    final items = [
      _StatItem(value: _formatCount(profile.karma), label: 'Karma'),
      _StatItem(value: '0', label: 'Contributions', hasChevron: true),
      _StatItem(
        value: _calculateAccountAge(profile.createdAt),
        label: 'Account Age',
      ),
      _StatItem(value: '0', label: 'Active In'),
    ];

    return IntrinsicHeight(
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            Expanded(child: _buildStatCell(context, items[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCell(BuildContext context, _StatItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              if (item.hasChevron) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => IconButton(
    icon: Icon(icon, size: 22),
    onPressed: onTap,
    style: IconButton.styleFrom(
      backgroundColor: Colors.black.withOpacity(0.35),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(36, 36),
    ),
  );

  // ───────────────────────────────────────────────────────────────────────────
  // Tabs
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPostsTab(BuildContext context) => _buildEmptyState(
    context,
    icon: Icons.article_outlined,
    title: 'No posts yet',
    subtitle: 'Posts you create will show up here',
  );

  Widget _buildCommentsTab(BuildContext context) => _buildEmptyState(
    context,
    icon: Icons.chat_bubble_outline,
    title: 'No comments yet',
    subtitle: 'Comments you write will show up here',
  );

  Widget _buildAboutTab(BuildContext context, UserProfileModel profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAboutTile(
          context,
          icon: Icons.cake_outlined,
          title: 'Cake Day',
          value: profile.createdAt != null
              ? _formatDate(profile.createdAt!)
              : 'Unknown',
        ),
        const Divider(height: 1),
        _buildAboutTile(
          context,
          icon: Icons.person_outline,
          title: 'Username',
          value: 'u/${profile.username}',
        ),
        if (profile.fullName != null && profile.fullName!.isNotEmpty) ...[
          const Divider(height: 1),
          _buildAboutTile(
            context,
            icon: Icons.badge_outlined,
            title: 'Full Name',
            value: profile.fullName!,
          ),
        ],
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const Divider(height: 1),
          _buildAboutTile(
            context,
            icon: Icons.info_outline,
            title: 'Bio',
            value: profile.bio!,
          ),
        ],
        const Divider(height: 1),
        _buildAboutTile(
          context,
          icon: Icons.bolt_outlined,
          title: 'Karma',
          value: _formatCount(profile.karma),
        ),
        const Divider(height: 1),
        _buildAboutTile(
          context,
          icon: Icons.group_outlined,
          title: 'Followers',
          value: _formatCount(profile.followersCount),
        ),
        const Divider(height: 1),
        _buildAboutTile(
          context,
          icon: Icons.person_add_outlined,
          title: 'Following',
          value: _formatCount(profile.followingCount),
        ),
      ],
    );
  }

  Widget _buildAboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Bottom sheet
  // ───────────────────────────────────────────────────────────────────────────

  void _showOptionsSheet(BuildContext context, UserProfileModel profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: profile),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────────

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  String _calculateAccountAge(DateTime? createdAt) {
    if (createdAt == null) return 'N/A';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    return '${diff.inDays}d';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class for stat cells
// ─────────────────────────────────────────────────────────────────────────────
class _StatItem {
  final String value;
  final String label;
  final bool hasChevron;
  const _StatItem({
    required this.value,
    required this.label,
    this.hasChevron = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky TabBar delegate
// ─────────────────────────────────────────────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  const _StickyTabBarDelegate({required this.tabBar, required this.color});

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
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar || oldDelegate.color != color;
}
