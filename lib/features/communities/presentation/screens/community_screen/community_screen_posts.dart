part of '../community_screen.dart';

extension _CommunityScreenPosts on _CommunityScreenState {
  Widget _buildPostList(
    AsyncValue<List<FeedPostModel>> postsState,
    RedditTokens tokens,
  ) {
    final detailsState = ref.watch(communityDetailsProvider);

    return detailsState.maybeWhen(
      data: (details) => postsState.when(
        data: (posts) {
          if (posts.isEmpty) return _emptyState(tokens);

          final isAdmin = details.userStatus.isAdmin;
          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
          final isOwner = details.community?.createdBy == currentUserId;

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              final isOwn = post.authorId == currentUserId;
              final canDelete = isOwn || isAdmin || isOwner;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FeedPostCard(
                  post: post,
                  onTap: () => _navigateToPost(post.id),
                  onUpvote: () =>
                      ref.read(fetchCommunityPostsProvider.notifier).votePost(
                            postId: post.id,
                            value: 1,
                            authorId: post.authorId,
                          ),
                  onDownvote: () =>
                      ref.read(fetchCommunityPostsProvider.notifier).votePost(
                            postId: post.id,
                            value: -1,
                            authorId: post.authorId,
                          ),
                  onComment: () => _navigateToPost(post.id),
                  onDelete: canDelete ? () => _handleDelete(post.id) : null,
                  onShare: () => _copyPostLink(post.id),
                  onSave: () async {
                    if (post.isSaved) {
                      ref
                          .read(savePostProvider(post.id).notifier)
                          .unsavePost(post.id);
                    } else {
                      ref
                          .read(savePostProvider(post.id).notifier)
                          .savePost(post.id);
                    }
                    ref
                        .read(fetchCommunityPostsProvider.notifier)
                        .updatePostLocally(post.toggleSave());
                    return !post.isSaved;
                  },
                ),
              );
            }, childCount: posts.length),
          );
        },
        loading: () => SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
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
      ),
      orElse: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: SkeletonLoader(height: 200),
          ),
          childCount: 3,
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
                onPressed: () {},
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
