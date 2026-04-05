// lib/features/post/presentation/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';
import 'package:mini_reddit_v2/core/widgets/post_images_carousel.dart';

class PostCard extends StatelessWidget {
  final PostDetailsModel post;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onFollow;

  const PostCard({
    super.key,
    required this.post,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onTap,
    this.onShare,
    this.onSave,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTitle(context),
          // _buildContent(context),
          _buildMediaContent(context),
          _buildFooter(context),
          const Divider(height: 1),
        ],
      ),
    );
  }

  // ============= HEADER SECTION =============
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 12),
          Expanded(child: _buildPostInfo(context)),
          // _buildFollowButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? avatarUrl = post.communityName.isNotEmpty
        ? post.communityImageUrl
        : post.authorAvatarUrl;

    return GestureDetector(
      onTap: () {
        // Navigate to community/profile
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(
                post.communityName.isNotEmpty ? Icons.group : Icons.person,
                size: 20,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              )
            : null,
      ),
    );
  }

  Widget _buildPostInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasCommunity = post.communityName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCommunity) ...[
          GestureDetector(
            onTap: () {
              // Navigate to community
            },
            child: Text(
              'r/${post.communityName}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
        Row(
          children: [
            Text(
              'u/${post.authorUsername}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(width: 4),
            Text('•', style: TextStyle(color: theme.hintColor, fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              TimeFormatter.getTimeAgo(post.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    if (post.communityName.isEmpty) return const SizedBox.shrink();

    return OutlinedButton(
      onPressed: onFollow,
      style: OutlinedButton.styleFrom(
        foregroundColor: RedditConstants.orange,
        side: const BorderSide(color: RedditConstants.orange, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(64, 28),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Follow',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ============= TITLE SECTION =============
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        post.content,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.3,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // // ============= CONTENT SECTION =============
  // Widget _buildContent(BuildContext context) {
  //   if (post.content.isEmpty) {
  //     return const SizedBox.shrink();
  //   }

  //   final theme = Theme.of(context);

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Text(
  //       post.content,
  //       style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
  //     ),
  //   );
  // }

  // ============= MEDIA SECTION =============
  Widget _buildMediaContent(BuildContext context) {
    if (post.images.isNotEmpty) {
      return _buildImageGallery(context);
    } else if (post.postType == 'link' && post.linkUrl != null) {
      return _buildLinkPreview(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageGallery(BuildContext context) {
    final urls = post.images
        .map((e) => e.imageUrl)
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: PostImagesCarousel(
        imageUrls: urls,
        aspectRatio: 4 / 3,
        borderRadius: 12,
      ),
    );
  }

  Widget _buildLinkPreview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.linkUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  post.linkUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: isDark
                            ? Colors.blue.shade300
                            : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _extractDomain(post.linkUrl!),
                          style: TextStyle(
                            color: isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // if (post.title != null) ...[
                  //   const SizedBox(height: 8),
                  //   Text(
                  //     post.title,
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 15,
                  //     ),
                  //     maxLines: 2,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ],
                  if (post.linkUrl != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.linkUrl!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildVideoPlaceholder(BuildContext context) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     child: Container(
  //       height: 200,
  //       decoration: BoxDecoration(
  //         color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(
  //               Icons.play_circle_outline,
  //               size: 48,
  //               color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               'Video content',
  //               style: TextStyle(
  //                 color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  // ============= FOOTER SECTION =============
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          _buildVoteButtons(context),
          const SizedBox(width: 12),
          _buildActionButton(
            context,
            icon: Icons.mode_comment_outlined,
            label: TimeFormatter.formatNumber(post.commentsCount),
            onTap: onComment,
          ),
          const SizedBox(width: 12),
          // _buildActionButton(
          //   context,
          //   icon: Icons.share_outlined,
          //   label: 'Share',
          //   onTap: onShare ?? () => _showShareSheet(context),
          // ),
          // const Spacer(),
          // _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildVoteButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade100;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVoteButton(
            icon: post.userVote == 1
                ? Icons.arrow_upward
                : Icons.arrow_upward_outlined,
            color: post.userVote == 1
                ? RedditConstants.upvote
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            onTap: onUpvote,
            isLeft: true,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              TimeFormatter.formatNumber(post.score),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: post.userVote == 1
                    ? RedditConstants.upvote
                    : post.userVote == -1
                    ? RedditConstants.downvote
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
          ),
          _buildVoteButton(
            icon: post.userVote == -1
                ? Icons.arrow_downward
                : Icons.arrow_downward_outlined,
            color: post.userVote == -1
                ? RedditConstants.downvote
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            onTap: onDownvote,
            isRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isLeft = false,
    bool isRight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(isLeft ? 20 : 0),
        right: Radius.circular(isRight ? 20 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSaveButton(BuildContext context) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;
  //   final isSaved = post.isSaved ?? false;

  //   return IconButton(
  //     icon: Icon(
  //       isSaved ? Icons.bookmark : Icons.bookmark_border,
  //       size: 22,
  //       color: isSaved
  //           ? RedditConstants.orange
  //           : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
  //     ),
  //     onPressed: onSave,
  //     splashRadius: 20,
  //   );
  // }

  // ============= SHARE SHEET =============
  void _showShareSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                // Copy link logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share via...'),
              onTap: () {
                Navigator.pop(context);
                // Share logic
              },
            ),
            if (onSave != null)
              ListTile(
                leading: Icon(
                  Icons.bookmark_border,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                title: const Text('Save Post'),
                onTap: () {
                  Navigator.pop(context);
                  onSave?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
