import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/feed/presentation/widgets/post_card.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_comments_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_posts_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/profile_comment_tile.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_active_in.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_common_widgets.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_formatters.dart';

class UserProfileBlockedView extends StatelessWidget {
  const UserProfileBlockedView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: tokens.bgPage,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Text(
        'This user is blocked.\nUnblock from the top-right menu to view posts and comments.',
        textAlign: TextAlign.center,
        style: context.rTypo.bodyMedium.copyWith(
          color: tokens.textSecondary,
          height: 1.35,
        ),
      ),
    );
  }
}

class UserProfilePostsTab extends ConsumerWidget {
  final String userId;
  final String searchQuery;

  const UserProfilePostsTab({
    super.key,
    required this.userId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(userPostsProvider(userId));
    return Container(
      color: tokens.bgPage,
      child: state.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: tokens.brandBlue)),
        error: (error, _) => Center(
          child: Text(
            'Failed to load posts\n$error',
            textAlign: TextAlign.center,
            style: context.rTypo.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ),
        data: (posts) {
          final filtered = searchQuery.isEmpty
              ? posts
              : posts.where((p) {
                  final text = '${p.title} ${p.content} ${p.communityName}'
                      .toLowerCase();
                  return text.contains(searchQuery);
                }).toList();
          if (filtered.isEmpty) {
            return Center(
              child: Text(
                searchQuery.isEmpty ? 'No posts yet' : 'No matching posts',
                style: context.rTypo.bodyMedium.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(userPostsProvider(userId).notifier)
                .fetchUserPosts(forceRefresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text('Feed Options'),
                      ),
                    ),
                  );
                }
                final post = filtered[index - 1];
                return FeedPostCard(
                  post: post,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailsScreen(postId: post.id),
                    ),
                  ),
                  onComment: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailsScreen(postId: post.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class UserProfileCommentsTab extends ConsumerWidget {
  final String userId;
  final String searchQuery;

  const UserProfileCommentsTab({
    super.key,
    required this.userId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(userCommentsProvider(userId));
    return Container(
      color: tokens.bgPage,
      child: state.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: tokens.brandBlue)),
        error: (error, _) => Center(
          child: Text(
            'Failed to load comments\n$error',
            textAlign: TextAlign.center,
            style: context.rTypo.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ),
        data: (comments) {
          final filtered = searchQuery.isEmpty
              ? comments
              : comments.where((c) {
                  final text = '${c.content} ${c.postTitle} ${c.communityName}'
                      .toLowerCase();
                  return text.contains(searchQuery);
                }).toList();
          if (filtered.isEmpty) {
            return Center(
              child: Text(
                searchQuery.isEmpty
                    ? 'No comments yet'
                    : 'No matching comments',
                style: context.rTypo.bodyMedium.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(userCommentsProvider(userId).notifier)
                .fetchUserComments(forceRefresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return ProfileCommentTile(
                  item: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailsScreen(postId: item.postId),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class UserProfileAboutTab extends StatelessWidget {
  final UserProfileModel profile;
  final int followersCount;
  final List<ActiveCommunity> communities;

  const UserProfileAboutTab({
    super.key,
    required this.profile,
    required this.followersCount,
    required this.communities,
  });

  @override
  Widget build(BuildContext context) {
    final communityText = communities.isEmpty
        ? 'No communities yet'
        : communities.map((c) => 'r/${c.name}').join(', ');

    return Container(
      color: context.tokens.bgPage,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ProfileAboutTile(
            title: 'Followers',
            value: formatProfileCount(followersCount),
          ),
          ProfileAboutTile(
            title: 'Following',
            value: formatProfileCount(profile.followingCount),
          ),
          ProfileAboutTile(
            title: 'Karma',
            value: formatProfileCount(profile.karma),
          ),
          const ProfileAboutTile(title: 'Date of birth', value: 'Not shared'),
          ProfileAboutTile(
            title: 'Bio',
            value: (profile.bio ?? '').trim().isEmpty ? 'No bio' : profile.bio!,
          ),
          ProfileAboutTile(
            title: 'Active in communities',
            value: communityText,
          ),
        ],
      ),
    );
  }
}
