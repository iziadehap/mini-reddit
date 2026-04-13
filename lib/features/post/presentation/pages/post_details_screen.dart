import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_state.dart';
import 'package:mini_reddit_v2/features/post/presentation/widgets/build_add_comment.dart';
import 'package:mini_reddit_v2/features/post/presentation/widgets/build_commints.dart';
import 'package:mini_reddit_v2/features/post/presentation/widgets/post_card.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(postProvider.notifier).getPostDetails(postId: widget.postId);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    final tokens = context.tokens;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.rTypo.bodyMedium.copyWith(color: tokens.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        backgroundColor: tokens.bgElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);
    final tokens = context.tokens;

    ref.listen(postProvider, (previous, next) {
      if (next.hasError && !next.showFullScreenError && !next.isSnackBarShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showErrorSnackBar(next.errorMessage ?? 'Error');
          ref.read(postProvider.notifier).resetSnackBarFlag();
        });
      }
    });

    return Scaffold(
      backgroundColor: tokens.bgPage,
      appBar: AppBar(
        backgroundColor: tokens.bgSurface,
        foregroundColor: tokens.textPrimary,
        title: Text('Post', style: context.rTypo.titleMedium),
      ),
      body: _buildBody(context, postState),
    );
  }

  Widget _buildBody(BuildContext context, PostState state) {
    final tokens = context.tokens;

    if (state.isLoading && state.post == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: tokens.brandOrange),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Loading post...',
              style: context.rTypo.bodyMedium.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.showFullScreenError) {
      return ColoredBox(
        color: tokens.bgPage,
        child: ErrorWidgetCustom(
          message: state.errorMessage ?? 'Something went wrong',
          onRetry: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref
                    .read(postProvider.notifier)
                    .getPostDetails(postId: widget.postId);
              }
            });
          },
        ),
      );
    }

    if (state.post == null) {
      return ColoredBox(
        color: tokens.bgPage,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: tokens.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text('Post not found', style: context.rTypo.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This post may have been removed.',
                style: context.rTypo.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: tokens.bgCanvas,
      child: RefreshIndicator(
        color: tokens.brandOrange,
        backgroundColor: tokens.bgSurface,
        onRefresh: () async {
          await ref
              .read(postProvider.notifier)
              .getPostDetails(postId: widget.postId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              PostCard(
                post: state.post!,
                onUpvote: () {
                  ref
                      .read(postProvider.notifier)
                      .votePost(postId: state.post!.id, value: 1);
                },
                onDownvote: () {
                  ref
                      .read(postProvider.notifier)
                      .votePost(postId: state.post!.id, value: -1);
                },
              ),
              Divider(height: 1, thickness: 0.8, color: tokens.divider),
              const BuildAddComment(),
              BuildCommentsSection(comments: state.post!.comments),
            ],
          ),
        ),
      ),
    );
  }
}
