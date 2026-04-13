import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/get_feed_type.dart';
import 'package:mini_reddit_v2/core/widgets/custom_snackbar.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/core/riverpod/ui_visibility_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/communities_screen.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_state.dart';
import 'package:mini_reddit_v2/core/riverpod/snackbar_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/community_drawer.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/empty_feed_widget.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/custom_app_bar.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/save_post_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/pages/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeFeed();
  }

  Future<void> _initializeFeed() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final feedType = await getFeedType(ref);
      // debugPrint('Feed type: $feedType');

      final notifier = ref.read(feedProvider.notifier);
      if (ref.read(feedProvider).feedType == feedType) {
        notifier.firstFetchFeed();
      } else {
        notifier.setFeedType(feedType);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // UI Visibility logic (for bottom navigation bar)
    final currentOffset = position.pixels;
    if (currentOffset > _lastScrollOffset && currentOffset > 100) {
      if (ref.read(uiVisibilityProvider)) {
        ref.read(uiVisibilityProvider.notifier).state = false;
      }
    } else if (currentOffset < _lastScrollOffset - 10 || currentOffset <= 0) {
      if (!ref.read(uiVisibilityProvider)) {
        ref.read(uiVisibilityProvider.notifier).state = true;
      }
    }
    _lastScrollOffset = currentOffset;

    // Load more logic
    if (position.pixels >= position.maxScrollExtent - 300) {
      final state = ref.read(feedProvider);

      if (state.feed?.isEmpty ?? true) return;
      if (state.isLoadMore || state.isEnd || state.isLoading) return;

      ref.read(feedProvider.notifier).loadMoreFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    await ref.read(feedProvider.notifier).firstFetchFeed();
  }

  void _handleDeletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(StringConstants.deletePost),
        content: const Text(StringConstants.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(StringConstants.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(communitiesActionsProvider.notifier)
                    .removePost(postId);
                if (mounted) {
                  final isDark =
                      // ignore: use_build_context_synchronously
                      Theme.of(context).brightness == Brightness.dark;
                  showCustomSnackBar(
                    context,
                    isDark: isDark,
                    message: 'Post deleted successfully',
                    icon: Icons.check,
                    color: Colors.green,
                    isError: false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  showCustomSnackBar(
                    context,
                    isDark: isDark,
                    message: 'Failed to delete post: $e',
                    icon: Icons.error,
                    color: Colors.red,
                    isError: true,
                  );
                }
              }
            },
            child: const Text(
              StringConstants.delete,
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

  void _handleVote(String postId, int value) {
    final post =
        ref.read(feedProvider).feed?.firstWhere((post) => post.id == postId);
    if (post == null) return;
    ref
        .read(feedProvider.notifier)
        .votePost(postId: postId, value: value, authorId: post.authorId);
  }

  Future<bool> _handleSave(String postId) async {
    final post =
        ref.read(feedProvider).feed?.firstWhere((post) => post.id == postId);
    if (post == null) return false;

    if (post.isSaved) {
      ref.read(savePostProvider(postId).notifier).unsavePost(postId);
    } else {
      ref.read(savePostProvider(postId).notifier).savePost(postId);
    }

    ref.read(feedProvider.notifier).updateFeedPostLocally(post.toggleSave());
    return !post.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    ref.listen(snackBarProvider, (previous, next) {
      if (next != null) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        showCustomSnackBar(
          context,
          isDark: isDark,
          message: next,
          icon: Icons.error,
          color: Colors.red,
          isError: true,
        );
        ref.read(snackBarProvider.notifier).state = null;
      }
    });

    ref.listen(savePostSnackBarProvider, (previous, next) {
      if (next != null) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        showCustomSnackBar(
          context,
          isDark: isDark,
          message: next.message,
          icon: next.isError ? Icons.error : Icons.check_circle,
          color: next.isError ? Colors.red : Colors.green,
          isError: next.isError,
        );
        ref.read(savePostSnackBarProvider.notifier).state = null;
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const CommunityDrawer(),
      // endDrawer: const UserDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        color: context.tokens.brandOrange,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarHeight: 70,
              titleSpacing: 0,
              title: CustomAppBar(
                openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                onSearch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnifiedSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            _buildFeedContent(feedState),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(FeedState feedState) {
    if (feedState.isLoading && feedState.isFirstLoad) {
      return _buildLoadingShimmer();
    }

    if (feedState.error != null && (feedState.feed?.isEmpty ?? true)) {
      return _buildErrorState(feedState.error!);
    }

    final posts = feedState.feed ?? [];
    if (posts.isEmpty) {
      return EmptyFeedWidget(
        onFindCommunities: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunitiesScreen()),
          );
        },
        onExplorePopular: () {
          ref.read(feedProvider.notifier).setFeedType(FeedType.popular);
        },
        onCommunityTap: (communityName) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityScreen(communityId: communityName),
            ),
          );
        },
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == posts.length) {
          return feedState.isLoadMore
              ? _buildLoadingMore()
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
            // onDelete: () => _handleDeletePost(post.id),
            onSave: () => _handleSave(post.id),
            onDelete:
                post.authorId == Supabase.instance.client.auth.currentUser?.id
                    ? () => _handleDeletePost(post.id)
                    : null,
          ),
        );
      }, childCount: posts.length + 1),
    );
  }

  Widget _buildLoadingShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: SkeletonLoader(height: 200),
        ),
        childCount: 5,
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(context.tokens.brandOrange),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorWidgetCustom(
        message: 'Failed to load feed: $error',
        onRetry: _refreshFeed,
      ),
    );
  }
}
