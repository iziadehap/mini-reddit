import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/community_details_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_community_posts_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/widgets/community_header.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/create_post_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityScreen({super.key, required this.communityId});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Offset threshold (px) after which the app bar title fades in.
  static const double _stickyTitleThreshold = 150.0;
  bool _showStickyTitle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final show =
        _scrollController.hasClients &&
        _scrollController.offset > _stickyTitleThreshold;
    if (show != _showStickyTitle) setState(() => _showStickyTitle = show);
  }

  void _fetchData() {
    ref
        .read(communityDetailsProvider.notifier)
        .fetchCommunityDetails(widget.communityId);
    ref
        .read(fetchCommunityPostsProvider.notifier)
        .fetchCommunityPosts(widget.communityId);
  }

  Future<void> _refresh() async => _fetchData();

  void _navigateToPost(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: postId)),
    );
  }

  void _handleDelete(String postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final detailsState = ref.watch(communityDetailsProvider);
    final postsState = ref.watch(fetchCommunityPostsProvider);

    return Scaffold(
      backgroundColor: tokens.bgCanvas,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: tokens.brandOrange,
        backgroundColor: tokens.bgSurface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, detailsState, tokens),
            _buildHeader(detailsState),
            _buildPostList(postsState, tokens),
          ],
        ),
      ),
      // FAB: create post (only visible when user is a member)
      floatingActionButton: detailsState.whenOrNull(
        data: (details) => details.userStatus.isMember
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreatePostScreen(initialCommunity: details.community),
                    ),
                  );
                },
                backgroundColor: tokens.brandOrange,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    AsyncValue<CommunityDetailsModel> detailsState,
    RedditTokens tokens,
  ) {
    return SliverAppBar(
      expandedHeight: 20,
      pinned: true,
      backgroundColor: tokens.bgSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: AnimatedOpacity(
        opacity: _showStickyTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 180),
        child: Row(
          children: [
            // Small avatar in sticky bar
            detailsState.whenOrNull(
                  data: (details) {
                    final community = details.community;
                    if (community == null) return null;
                    return CircleAvatar(
                      radius: 14,
                      backgroundColor: tokens.brandOrange,
                      backgroundImage: community.imageUrl != null
                          ? NetworkImage(community.imageUrl!)
                          : null,
                      child: community.imageUrl == null
                          ? Text(
                              community.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    );
                  },
                ) ??
                const SizedBox.shrink(),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'r/${widget.communityId}',
                style: context.rTypo.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      // actions: [
      //   // Edit action visible in the sticky bar for moderators
      //   detailsState.whenOrNull(
      //         data: (details) {
      //           if (!details.userStatus.isAdmin) return null;
      //           return IconButton(
      //             icon: Icon(Icons.edit_outlined, color: tokens.textPrimary),
      //             tooltip: 'Edit community',
      //             onPressed: details.community != null
      //                 ? () => _openEditSheet(details.community!)
      //                 : null,
      //           );
      //         },
      //       ) ??
      //       const SizedBox.shrink(),
      //   IconButton(
      //     icon: Icon(Icons.share_outlined, color: tokens.textPrimary),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.more_horiz, color: tokens.textPrimary),
      //     onPressed: () {},
      //   ),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            detailsState.when(
              data: (details) => details.community?.bannerUrl != null
                  ? Image.network(
                      details.community!.bannerUrl!,
                      fit: BoxFit.cover,
                    )
                  : _defaultBanner(tokens),
              loading: () => _defaultBanner(tokens),
              error: (_, __) => _defaultBanner(tokens),
            ),
            // Gradient overlay so back button stays legible
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.45), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultBanner(RedditTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.brandOrangeDark, tokens.brandOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ─── Community Header ─────────────────────────────────────────
  Widget _buildHeader(AsyncValue<CommunityDetailsModel> detailsState) {
    return detailsState.when(
      data: (details) =>
          SliverToBoxAdapter(child: CommunityHeader(details: details)),
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SkeletonLoader(height: 160),
        ),
      ),
      error: (err, _) => SliverToBoxAdapter(
        child: ErrorWidgetCustom(
          message: 'Failed to load community: $err',
          onRetry: _fetchData,
        ),
      ),
    );
  }

  // // ─── Sort Bar ─────────────────────────────────────────────────
  // Widget _buildSortBar(RedditTokens tokens) {
  //   return SliverPersistentHeader(
  //     pinned: true,
  //     delegate: _SortBarDelegate(tokens: tokens),
  //   );
  // }

  // ─── Post List ────────────────────────────────────────────────
  Widget _buildPostList(
    AsyncValue<List<FeedPostModel>> postsState,
    RedditTokens tokens,
  ) {
    return postsState.when(
      data: (posts) {
        if (posts.isEmpty) return _emptyState(tokens);

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = posts[index];
            final isOwn =
                post.authorId == Supabase.instance.client.auth.currentUser?.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FeedPostCard(
                post: post,
                onTap: () => _navigateToPost(post.id),
                onUpvote: () => ref
                    .read(fetchCommunityPostsProvider.notifier)
                    .votePost(
                      postId: post.id,
                      value: 1,
                      authorId: post.authorId,
                    ),
                onDownvote: () => ref
                    .read(fetchCommunityPostsProvider.notifier)
                    .votePost(
                      postId: post.id,
                      value: -1,
                      authorId: post.authorId,
                    ),
                onComment: () => _navigateToPost(post.id),
                onDelete: isOwn ? () => _handleDelete(post.id) : null,
              ),
            );
          }, childCount: posts.length),
        );
      },
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: SkeletonLoader(height: 200),
          ),
          childCount: 3,
        ),
      ),
      error: (err, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorWidgetCustom(
          message: 'Failed to load posts: $err',
          onRetry: _fetchData,
        ),
      ),
    );
  }

  Widget _emptyState(RedditTokens tokens) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: tokens.bgElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 40,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('No posts yet', style: context.rTypo.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Be the first to post in r/${widget.communityId}!',
                style: context.rTypo.bodyMedium.copyWith(
                  color: tokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: navigate to create post
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Post'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.brandOrange,
                  side: BorderSide(color: tokens.brandOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // ─── Sort Bar Delegate ────────────────────────────────────────
// class _SortBarDelegate extends SliverPersistentHeaderDelegate {
//   final RedditTokens tokens;

//   _SortBarDelegate({required this.tokens});

//   @override
//   double get minExtent => 48;
//   @override
//   double get maxExtent => 48;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: tokens.bgCanvas,
//       child: Row(
//         children: [
//           const SizedBox(width: AppSpacing.lg),
//           _SortChip(
//             label: 'Hot',
//             icon: Icons.local_fire_department,
//             selected: true,
//             tokens: tokens,
//           ),
//           const SizedBox(width: AppSpacing.sm),
//           _SortChip(
//             label: 'New',
//             icon: Icons.fiber_new_outlined,
//             selected: false,
//             tokens: tokens,
//           ),
//           const SizedBox(width: AppSpacing.sm),
//           _SortChip(
//             label: 'Top',
//             icon: Icons.bar_chart,
//             selected: false,
//             tokens: tokens,
//           ),
//           const Spacer(),
//           IconButton(
//             icon: Icon(Icons.tune, size: 20, color: tokens.textSecondary),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   bool shouldRebuild(_SortBarDelegate oldDelegate) => false;
// }
