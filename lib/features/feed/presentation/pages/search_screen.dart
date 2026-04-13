import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_communities_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/search_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/features/search/presentation/riverpod/user_search_provider.dart';
import 'package:mini_reddit_v2/features/search/presentation/widgets/user_search_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SearchTab { posts, communities, users }

// ---------------------------------------------------------------------------
// Trending topics shown when the search bar is empty
// ---------------------------------------------------------------------------
const _kTrendingTopics = [
  '🔥 r/technology',
  '🎮 r/gaming',
  '🐶 r/aww',
  '📰 r/worldnews',
  '💡 r/todayilearned',
  '🎬 r/movies',
];

class UnifiedSearchScreen extends ConsumerStatefulWidget {
  const UnifiedSearchScreen({super.key});

  @override
  ConsumerState<UnifiedSearchScreen> createState() =>
      _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends ConsumerState<UnifiedSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  SearchTab _activeTab = SearchTab.posts;
  late TabController _tabController;

  // ── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── event handlers ────────────────────────────────────────────────────────

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() => _activeTab = SearchTab.values[_tabController.index]);
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 300) return;

    switch (_activeTab) {
      case SearchTab.posts:
        final s = ref.read(searchProvider);
        if (s.feed?.isEmpty ?? true) return;
        if (s.isLoadMore || s.isEnd || s.isLoading) return;
        ref.read(searchProvider.notifier).loadMoreFeed();
        break;
      case SearchTab.communities:
        break;
      case SearchTab.users:
        final s = ref.read(userSearchProvider);
        if (s.users.isEmpty || s.isLoadMore || s.isEnd || s.isLoading) return;
        ref.read(userSearchProvider.notifier).loadMore();
        break;
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.trim().isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  void _performSearch(String query) {
    switch (_activeTab) {
      case SearchTab.posts:
        ref.read(searchProvider.notifier).setSearchQuery(query);
        break;
      case SearchTab.communities:
        ref.read(fetchCommunitiesProvider.notifier).fetchCommunities(search: query);
        break;
      case SearchTab.users:
        ref.read(userSearchProvider.notifier).searchUsers(query);
        break;
    }
  }

  void _handleVote(String postId, int value) {
    final post = ref.read(searchProvider).feed?.firstWhere(
          (p) => p.id == postId,
          orElse: () => throw Exception('Post not found'),
        );
    if (post == null) return;
    ref.read(searchProvider.notifier).votePost(
          postId: postId,
          value: value,
          authorId: post.authorId,
        );
  }

  void _handleDeletePost(String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(communitiesActionsProvider.notifier).removePost(postId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToPostDetails(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: postId)),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final query = ref.watch(searchQueryProvider);

    // Keep the TextField in sync without triggering _onSearchChanged again
    if (_searchController.text != query) {
      _searchController.value = _searchController.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(t, query),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildCommunitiesTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(dynamic t, String query) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 0,
      leadingWidth: 48,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      title: _SearchBar(
        controller: _searchController,
        query: query,
        onChanged: _onSearchChanged,
        onClear: () {
          _searchController.clear();
          _onSearchChanged('');
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _buildTabBar(t),
      ),
    );
  }

  Widget _buildTabBar(dynamic t) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: t.brandOrange),
          insets: const EdgeInsets.symmetric(horizontal: 24),
        ),
        labelColor: t.brandOrange,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article_outlined, size: 16),
                SizedBox(width: 6),
                Text('Posts'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_outlined, size: 16),
                SizedBox(width: 6),
                Text('Communities'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 16),
                SizedBox(width: 6),
                Text('Users'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Posts tab ─────────────────────────────────────────────────────────────

  Widget _buildPostsTab() {
    final t = context.tokens;
    final searchState = ref.watch(searchProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) {
      return _buildTrendingPlaceholder('posts');
    }

    if (searchState.isLoading && searchState.isFirstLoad) {
      return _buildSkeletonList(height: 200);
    }

    if (searchState.error != null && (searchState.feed?.isEmpty ?? true)) {
      return ErrorWidgetCustom(
        message: 'Failed to search posts: ${searchState.error}',
        onRetry: () => _performSearch(query),
      );
    }

    final posts = searchState.feed ?? [];
    if (posts.isEmpty) return _buildNoResults('posts', query);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: posts.length + 1,
      itemBuilder: (ctx, i) {
        if (i == posts.length) {
          return searchState.isLoadMore
              ? _buildLoadMoreIndicator(t)
              : const SizedBox(height: 80);
        }
        final post = posts[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: FeedPostCard(
            post: post,
            onTap: () => _navigateToPostDetails(post.id),
            onUpvote: () => _handleVote(post.id, 1),
            onDownvote: () => _handleVote(post.id, -1),
            onComment: () => _navigateToPostDetails(post.id),
            onDelete: post.authorId ==
                    Supabase.instance.client.auth.currentUser?.id
                ? () => _handleDeletePost(post.id)
                : null,
          ),
        );
      },
    );
  }

  // ── Communities tab ───────────────────────────────────────────────────────

  Widget _buildCommunitiesTab() {
    final communities = ref.watch(fetchCommunitiesProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) return _buildTrendingPlaceholder('communities');

    return communities.when(
      data: (data) {
        if (data.isEmpty) return _buildNoResults('communities', query);
        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: data.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 72,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
          itemBuilder: (ctx, i) => _CommunityTile(
            community: data[i],
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => CommunityScreen(communityId: data[i].id),
              ),
            ),
          ),
        );
      },
      loading: () => _buildSkeletonList(height: 72),
      error: (err, _) => ErrorWidgetCustom(
        message: 'Failed to search communities: $err',
        onRetry: () => _performSearch(query),
      ),
    );
  }

  // ── Users tab ─────────────────────────────────────────────────────────────

  Widget _buildUsersTab() {
    final t = context.tokens;
    final userState = ref.watch(userSearchProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) return _buildTrendingPlaceholder('users');

    if (userState.isLoading && userState.users.isEmpty) {
      return _buildSkeletonList(height: 72);
    }

    if (userState.error != null && userState.users.isEmpty) {
      return ErrorWidgetCustom(
        message: 'Failed to search users: ${userState.error}',
        onRetry: () => _performSearch(query),
      );
    }

    if (userState.users.isEmpty) return _buildNoResults('users', query);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: userState.users.length + 1,
      itemBuilder: (ctx, i) {
        if (i == userState.users.length) {
          return userState.isLoadMore
              ? _buildLoadMoreIndicator(t)
              : const SizedBox(height: 80);
        }
        return UserSearchCard(user: userState.users[i]);
      },
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildSkeletonList({required double height}) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SkeletonLoader(height: height),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(dynamic t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(t.brandOrange),
          ),
        ),
      ),
    );
  }

  /// Shown when the search field is empty – displays trending topics.
  Widget _buildTrendingPlaceholder(String tab) {
    final t = context.tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: t.brandOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trending today',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _kTrendingTopics
                .map(
                  (topic) => _TrendingChip(
                    label: topic,
                    onTap: () {
                      final clean =
                          topic.replaceAll(RegExp(r'^[^\w]+'), '').trim();
                      _searchController.text = clean;
                      _onSearchChanged(clean);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.manage_search_rounded,
                  size: 56,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.18),
                ),
                const SizedBox(height: 12),
                Text(
                  'Search for $tab',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String type, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 38,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No $type found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We searched everywhere but couldn\'t\nfind "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

/// Polished search bar extracted into its own widget.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 6, bottom: 6),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search Reddit…',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single community row with avatar + gradient fallback + join button.
class _CommunityTile extends StatelessWidget {
  const _CommunityTile({required this.community, required this.onTap});

  final dynamic community;
  final VoidCallback onTap;

  static const List<List<Color>> _gradients = [
    [Color(0xFFFF4500), Color(0xFFFF6534)],
    [Color(0xFF0DD3BB), Color(0xFF0588C6)],
    [Color(0xFF9B59B6), Color(0xFF6C3483)],
    [Color(0xFFE74C3C), Color(0xFFC0392B)],
    [Color(0xFF27AE60), Color(0xFF16A085)],
    [Color(0xFFF39C12), Color(0xFFD35400)],
  ];

  List<Color> _gradientFor(String name) {
    final idx = name.codeUnitAt(0) % _gradients.length;
    return _gradients[idx];
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        community.imageUrl != null && (community.imageUrl as String).isNotEmpty;
    final gradient = _gradientFor(community.name as String? ?? 'A');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasImage
                    ? null
                    : LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(community.imageUrl as String),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasImage
                  ? null
                  : Center(
                      child: Text(
                        (community.name as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'r/${community.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(community.membersCount as int? ?? 0),
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Join button
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF4500),
                side: const BorderSide(color: Color(0xFFFF4500), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Join',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Pill chip for trending topics.
class _TrendingChip extends StatelessWidget {
  const _TrendingChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}