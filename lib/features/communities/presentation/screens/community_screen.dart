import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_state.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/community_header.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  final String communityName;
  
  const CommunityScreen({super.key, required this.communityName});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      final state = ref.read(communityFeedProvider(widget.communityName));
      if (state.feed?.isEmpty ?? true) return;
      if (state.isLoadMore || state.isEnd || state.isLoading) return;
      ref
          .read(communityFeedProvider(widget.communityName).notifier)
          .loadMoreFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    await ref
        .read(communityFeedProvider(widget.communityName).notifier)
        .firstFetchFeed();
  }

  void _handleVote(FeedPostModel post, int value) {
    ref
        .read(communityFeedProvider(widget.communityName).notifier)
        .votePost(postId: post.id, value: value, authorId: post.authorId);
  }

  void _navigateToPostDetails(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsScreen(postId: postId),
      ),
    );
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(communityFeedProvider(widget.communityName));
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.bgCanvas,
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        color: tokens.brandOrange,
        backgroundColor: tokens.bgSurface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: tokens.bgSurface,
              floating: true,
              snap: true,
              elevation: 0,
              leading: BackButton(color: tokens.textPrimary),
              title: Text(
                'r/${widget.communityName}',
                style: context.rTypo.titleMedium,
              ),
              centerTitle: true,
            ),

            // Community Header (Banner, Icon, Name, Join Button)
            _buildCommunityHeader(feedState),

            // Feed Posts
            _buildFeedContent(feedState),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityHeader(FeedState feedState) {
    // Try to find the community model in the state
    final community = feedState.communities?.firstWhere(
      (c) => c.name == widget.communityName,
      orElse: () => CommunityModel.empty(name: widget.communityName),
    );

    if (community == null)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(child: CommunityHeader(community: community));
  }

  Widget _buildFeedContent(FeedState feedState) {
    if (feedState.isLoading && feedState.isFirstLoad) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: SkeletonLoader(height: 200),
          ),
          childCount: 3,
        ),
      );
    }

    if (feedState.error != null && (feedState.feed?.isEmpty ?? true)) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorWidgetCustom(
          message: 'Failed to load community feed: ${feedState.error}',
          onRetry: _refreshFeed,
        ),
      );
    }

    final posts = feedState.feed ?? [];
    if (posts.isEmpty && !feedState.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.post_add, size: 64, color: context.tokens.textMuted),
              const SizedBox(height: AppSpacing.md),
              Text('No posts yet', style: context.rTypo.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Be the first to post in r/${widget.communityName}!',
                style: context.rTypo.bodyMedium.copyWith(
                  color: context.tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == posts.length) {
          return feedState.isLoadMore
              ? _buildLoadingMore()
              : const SizedBox(height: 100);
        }

        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FeedPostCard(
            post: post,
            onTap: () => _navigateToPostDetails(post.id),
            onUpvote: () => _handleVote(post, 1),
            onDownvote: () => _handleVote(post, -1),
            onComment: () => _navigateToPostDetails(post.id),
            onDelete:
                post.authorId == Supabase.instance.client.auth.currentUser?.id
                ? () => _handleDeletePost(post.id)
                : null,
          ),
        );
      }, childCount: posts.length + 1),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(context.tokens.brandOrange),
        ),
      ),
    );
  }
}
