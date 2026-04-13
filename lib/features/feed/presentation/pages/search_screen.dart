import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_communities_provider.dart';
// import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fatch_communities_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/search_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/features/search/presentation/riverpod/user_search_provider.dart';
import 'package:mini_reddit_v2/features/search/presentation/widgets/user_search_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SearchTab { posts, communities, users }

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

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _activeTab = SearchTab.values[_tabController.index];
      });
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      switch (_activeTab) {
        case SearchTab.posts:
          final state = ref.read(searchProvider);
          if (state.feed?.isEmpty ?? true) return;
          if (state.isLoadMore || state.isEnd || state.isLoading) return;
          ref.read(searchProvider.notifier).loadMoreFeed();
          break;
        case SearchTab.communities:
          break;
        case SearchTab.users:
          final state = ref.read(userSearchProvider);
          if (state.users.isEmpty) return;
          if (state.isLoadMore || state.isEnd || state.isLoading) return;
          ref.read(userSearchProvider.notifier).loadMore();
          break;
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    ref.read(searchQueryProvider.notifier).state = query;

    if (query.trim().isEmpty) {
      return;
    }

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
        ref
            .read(fetchCommunitiesProvider.notifier)
            .fetchCommunities(search: query);
        break;
      case SearchTab.users:
        ref.read(userSearchProvider.notifier).searchUsers(query);
        break;
    }
  }

  void _handleVote(String postId, int value) {
    final post = ref.read(searchProvider).feed?.firstWhere(
          (post) => post.id == postId,
          orElse: () => throw Exception('Post not found'),
        );
    if (post == null) return;
    ref
        .read(searchProvider.notifier)
        .votePost(postId: postId, value: value, authorId: post.authorId);
  }

  void _handleDeletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(communitiesActionsProvider.notifier).removePost(postId);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPostDetails(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsScreen(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final query = ref.watch(searchQueryProvider);
    _searchController.text = query;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search Reddit',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posts', icon: Icon(Icons.article_outlined, size: 18)),
            Tab(
                text: 'Communities',
                icon: Icon(Icons.groups_outlined, size: 18)),
            Tab(text: 'Users', icon: Icon(Icons.person_outline, size: 18)),
          ],
          labelColor: t.brandOrange,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: t.brandOrange,
        ),
      ),
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

  Widget _buildPostsTab() {
    final t = context.tokens;
    final searchState = ref.watch(searchProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) {
      return _buildEmptyPlaceholder('Search for posts');
    }

    if (searchState.isLoading && searchState.isFirstLoad) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonLoader(height: 200),
        ),
      );
    }

    if (searchState.error != null && (searchState.feed?.isEmpty ?? true)) {
      return ErrorWidgetCustom(
        message: 'Failed to search posts: ${searchState.error}',
        onRetry: () => _performSearch(query),
      );
    }

    final posts = searchState.feed ?? [];
    if (posts.isEmpty) {
      return _buildNoResults('posts', query);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: posts.length + 1,
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return searchState.isLoadMore
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(t.brandOrange),
                    ),
                  ),
                )
              : const SizedBox(height: 80);
        }

        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FeedPostCard(
            post: post,
            onTap: () => _navigateToPostDetails(post.id),
            onUpvote: () => _handleVote(post.id, 1),
            onDownvote: () => _handleVote(post.id, -1),
            onComment: () => _navigateToPostDetails(post.id),
            onDelete:
                post.authorId == Supabase.instance.client.auth.currentUser?.id
                    ? () => _handleDeletePost(post.id)
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildCommunitiesTab() {
    final communities = ref.watch(fetchCommunitiesProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) {
      return _buildEmptyPlaceholder('Search for communities');
    }

    return communities.when(
      data: (data) {
        if (data.isEmpty) {
          return _buildNoResults('communities', query);
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final community = data[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CommunityScreen(communityId: community.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: community.imageUrl != null &&
                              community.imageUrl!.isNotEmpty
                          ? NetworkImage(community.imageUrl!)
                          : null,
                      child: community.imageUrl == null ||
                              community.imageUrl!.isEmpty
                          ? const Icon(Icons.groups, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'r/${community.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${community.membersCount} members',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonLoader(height: 70),
        ),
      ),
      error: (error, stack) => ErrorWidgetCustom(
        message: 'Failed to search communities: $error',
        onRetry: () => _performSearch(query),
      ),
    );
  }

  Widget _buildUsersTab() {
    final t = context.tokens;
    final userState = ref.watch(userSearchProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) {
      return _buildEmptyPlaceholder('Search for users');
    }

    if (userState.isLoading && userState.users.isEmpty) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonLoader(height: 70),
        ),
      );
    }

    if (userState.error != null && userState.users.isEmpty) {
      return ErrorWidgetCustom(
        message: 'Failed to search users: ${userState.error}',
        onRetry: () => _performSearch(query),
      );
    }

    if (userState.users.isEmpty) {
      return _buildNoResults('users', query);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: userState.users.length + 1,
      itemBuilder: (context, index) {
        if (index == userState.users.length) {
          return userState.isLoadMore
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(t.brandOrange),
                    ),
                  ),
                )
              : const SizedBox(height: 80);
        }

        final user = userState.users[index];
        return UserSearchCard(user: user);
      },
    );
  }

  Widget _buildEmptyPlaceholder(String hint) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hint,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String type, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No $type found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No results found for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
