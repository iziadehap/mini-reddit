import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/custom_snackbar.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/community_details_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_community_posts_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/widgets/community_header.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/create_post_screen.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/save_post_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'community_screen/community_screen_app_bar.dart';
part 'community_screen/community_screen_posts.dart';

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

  void _copyPostLink(String postId) {
    final link = '${RedditConstants.postDeepLinkPrefix}$postId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post link copied'),
        backgroundColor: context.tokens.bgElevated,
        behavior: SnackBarBehavior.floating,
      ),
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(communitiesActionsProvider.notifier)
                    .removePost(postId);
                if (mounted) {
                  final isDark =
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
}
