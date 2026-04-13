import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_saved_posts_provider.dart';
import 'package:mini_reddit_v2/core/widgets/shimmer_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/save_post_provider.dart';

class SavePostScreen extends ConsumerStatefulWidget {
  const SavePostScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SavePostScreenState();
}

class _SavePostScreenState extends ConsumerState<SavePostScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(userSavedPostsProvider.notifier).fetchSavedPosts();
  }

  //   @override
  //   Widget build(BuildContext context) {
  //     return const Placeholder();
  //   }
  // }

  // class SavePostScreen extends ConsumerWidget {
  //   const SavePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return Scaffold(
        backgroundColor: tokens.bgCanvas,
        body: Center(
          child: Text(
            'Not signed in',
            style: context.rTypo.bodyMedium.copyWith(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final savedAsync = ref.watch(userSavedPostsProvider);

    return Scaffold(
      backgroundColor: tokens.bgCanvas,
      appBar: AppBar(
        backgroundColor: tokens.bgCanvas,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        title: Text(
          'Saved',
          style: context.rTypo.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: tokens.textSecondary,
            onPressed: () => ref
                .read(userSavedPostsProvider.notifier)
                .fetchSavedPosts(forceRefresh: true),
          ),
        ],
      ),
      body: savedAsync.when(
        loading: () => _SavedPostsShimmerList(),
        error: (err, _) => ErrorWidgetCustom(
          message: err.toString(),
          onRetry: () => ref
              .read(userSavedPostsProvider.notifier)
              .fetchSavedPosts(forceRefresh: true),
        ),
        data: (posts) {
          debugPrint('saved posts ==: $posts');
          if (posts.isEmpty) {
            return _SavedEmptyState(tokens: tokens);
          }

          return RefreshIndicator(
            color: tokens.brandOrange,
            onRefresh: () => ref
                .read(userSavedPostsProvider.notifier)
                .fetchSavedPosts(forceRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final post = posts[index];
                return FeedPostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailsScreen(postId: post.id),
                      ),
                    );
                  },
                  onComment: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailsScreen(postId: post.id),
                      ),
                    );
                  },
                  onSave: () async {
                    if (post.isSaved) {
                      ref
                          .read(savePostProvider(post.id).notifier)
                          .unsavePost(post.id);
                      // Let userSavedPostsProvider handle removing it from local list if desired,
                      // or just toggle its property
                      // We'll trust the pull-to-refresh for now
                    } else {
                      ref
                          .read(savePostProvider(post.id).notifier)
                          .savePost(post.id);
                    }
                    return !post.isSaved;
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SavedEmptyState extends StatelessWidget {
  final RedditTokens tokens;
  const _SavedEmptyState({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 72, color: tokens.textMuted),
            const SizedBox(height: 16),
            Text(
              'No saved posts',
              style: context.rTypo.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'When you save posts, they show up here.',
              style: context.rTypo.bodyMedium.copyWith(
                color: tokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPostsShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _ShimmerSavedPostCard(tokens: tokens);
      },
    );
  }
}

class _ShimmerSavedPostCard extends StatelessWidget {
  final RedditTokens tokens;
  const _ShimmerSavedPostCard({required this.tokens});

  @override
  Widget build(BuildContext context) {
    final shimmerBase = Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBg,
        border: Border(
          bottom: BorderSide(color: tokens.cardBorder, width: 0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ).withShimmerAi(
                loading: true,
                width: 34,
                height: 34,
                decoration: const BoxDecoration(shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: shimmerBase,
                    ).withShimmerAi(
                      loading: true,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: shimmerBase,
                    ).withShimmerAi(
                      loading: true,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 16,
            width: MediaQuery.sizeOf(context).width * 0.75,
            color: shimmerBase,
          ).withShimmerAi(
            loading: true,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: double.infinity,
            color: shimmerBase,
          ).withShimmerAi(
            loading: true,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: MediaQuery.sizeOf(context).width * 0.65,
            color: shimmerBase,
          ).withShimmerAi(
            loading: true,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                height: 34,
                width: 120,
                decoration: BoxDecoration(
                  color: tokens.cardVoteBar,
                  borderRadius: BorderRadius.circular(20),
                ),
              ).withShimmerAi(
                loading: true,
                decoration: BoxDecoration(
                  color: tokens.cardVoteBar,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const Spacer(),
              Container(
                height: 34,
                width: 84,
                decoration: BoxDecoration(
                  color: tokens.cardVoteBar,
                  borderRadius: BorderRadius.circular(20),
                ),
              ).withShimmerAi(
                loading: true,
                decoration: BoxDecoration(
                  color: tokens.cardVoteBar,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
