// lib/features/feed/presentation/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const FeedPostCard({
    super.key,
    required this.post,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onTap,
    this.onDelete,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBg,
        border: Border(
          bottom: BorderSide(color: tokens.cardBorder, width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        highlightColor: tokens.brandOrange.withOpacity(0.05),
        splashColor: tokens.brandOrange.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildFlairIfPresent(context),
            _buildContent(context),
            _buildMediaContent(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ============= HEADER SECTION =============
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 8),
          Expanded(child: _buildPostInfo(context)),
          if (onDelete != null) _buildMoreButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final tokens = context.tokens;

    // Determine which avatar to show (community > author)
    String? avatarUrl = post.communityName.isNotEmpty
        ? post.communityImageUrl
        : post.authorAvatarUrl;

    return CircleAvatar(
      radius: 16,
      backgroundColor: tokens.bgElevated,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Icon(
              post.communityName.isNotEmpty ? Icons.group : Icons.person,
              size: 16,
              color: tokens.textSecondary,
            )
          : null,
    );
  }

  Widget _buildPostInfo(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (post.communityName.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  _goToCommunity(context, post.communityId);
                },
                child: Text(
                  'r/${post.communityName}',
                  style: typo.communityName.copyWith(
                    fontSize: 13,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.circle, size: 3, color: tokens.textMuted),
              const SizedBox(width: 4),
            ],
            Text('u/${post.authorUsername}', style: typo.postMeta),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          TimeFormatter.getTimeAgo(post.createdAt),
          style: typo.postMeta.copyWith(fontSize: 10, color: tokens.textMuted),
        ),
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final tokens = context.tokens;

    return IconButton(
      icon: Icon(Icons.more_horiz, size: 20, color: tokens.textSecondary),
      onPressed: () => _showPostMenu(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 20,
      tooltip: 'More options',
    );
  }

  // ============= FLAIR SECTION =============
  Widget _buildFlairIfPresent(BuildContext context) {
    if (post.flairName == null || post.flairName!.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final flairColor = post.flairColor != null
        ? Color(int.parse(post.flairColor!.replaceFirst('#', '0xff')))
        : tokens.brandOrange;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: flairColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: flairColor.withOpacity(0.3), width: 0.5),
        ),
        child: Text(
          post.flairName!,
          style: context.rTypo.labelSmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: flairColor,
          ),
        ),
      ),
    );
  }

  // ============= CONTENT SECTION =============
  Widget _buildContent(BuildContext context) {
    final typo = context.rTypo;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post title
          Text(
            post.title,
            style: typo.postTitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              post.content,
              style: typo.bodyMedium.copyWith(
                color: tokens.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ============= MEDIA SECTION =============
  Widget _buildMediaContent(BuildContext context) {
    if (post.images != null && post.images!.isNotEmpty) {
      return _buildImageContent(context);
    } else if (post.postType == 'link' && post.linkUrl != null) {
      return _buildLinkContent(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageContent(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            post.images!.first.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: tokens.bgElevated,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: tokens.textMuted,
                ),
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: tokens.bgElevated,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: tokens.brandOrange,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLinkContent(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tokens.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tokens.borderDefault, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.link, size: 18, color: tokens.brandBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _extractDomain(post.linkUrl!),
                    style: context.rTypo.labelMedium.copyWith(
                      color: tokens.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.linkUrl!,
                    style: context.rTypo.bodySmall.copyWith(
                      color: tokens.textMuted,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Row(
        children: [
          _buildVoteButtons(context),
          const SizedBox(width: 12),
          _buildCommentButton(context),
          const Spacer(),
          _buildShareButton(context),
        ],
      ),
    );
  }

  Widget _buildVoteButtons(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: tokens.cardVoteBar,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVoteButton(
            icon: post.userVote == 1
                ? Icons.arrow_upward
                : Icons.arrow_upward_outlined,
            color: post.userVote == 1 ? tokens.upvote : tokens.voteNeutral,
            onTap: onUpvote,
            isLeft: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              TimeFormatter.formatNumber(post.score),
              style: typo.voteCount.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: post.userVote == 1
                    ? tokens.upvote
                    : post.userVote == -1
                    ? tokens.downvote
                    : tokens.textSecondary,
              ),
            ),
          ),
          _buildVoteButton(
            icon: post.userVote == -1
                ? Icons.arrow_downward
                : Icons.arrow_downward_outlined,
            color: post.userVote == -1 ? tokens.downvote : tokens.voteNeutral,
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
        left: Radius.circular(isLeft ? 24 : 0),
        right: Radius.circular(isRight ? 24 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return InkWell(
      onTap: onComment,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: tokens.cardVoteBar,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mode_comment_outlined,
              size: 18,
              color: tokens.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              TimeFormatter.formatNumber(post.commentsCount),
              style: typo.commentCount.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    final tokens = context.tokens;

    return IconButton(
      icon: Icon(Icons.share_outlined, size: 20, color: tokens.textSecondary),
      onPressed: onShare ?? () => _showShareSheet(context),
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: 'Share',
    );
  }

  // ============= MENU AND ACTIONS =============
  void _showPostMenu(BuildContext context) {
    final tokens = context.tokens;

    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSave != null)
              ListTile(
                leading: Icon(
                  Icons.bookmark_border,
                  color: tokens.textSecondary,
                ),
                title: Text('Save Post', style: context.rTypo.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  onSave?.call();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Post',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.report_outlined, color: tokens.textSecondary),
              title: Text('Report Post', style: context.rTypo.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                // Handle report
                _showReportSnackbar(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final tokens = context.tokens;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Post?', style: context.rTypo.titleMedium),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete this post?',
          style: context.rTypo.bodyMedium.copyWith(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: tokens.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    final tokens = context.tokens;

    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: tokens.textSecondary),
              title: Text('Copy Link', style: context.rTypo.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _copyLinkToClipboard(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: tokens.textSecondary),
              title: Text('Share via...', style: context.rTypo.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                // Handle share via native share sheet
              },
            ),
            if (onSave != null)
              ListTile(
                leading: Icon(
                  Icons.bookmark_border,
                  color: tokens.textSecondary,
                ),
                title: Text('Save Post', style: context.rTypo.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  onSave?.call();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _copyLinkToClipboard(BuildContext context) {
    // TODO: Implement copy to clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        backgroundColor: context.tokens.bgElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReportSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report submitted. We\'ll review it.'),
        backgroundColor: context.tokens.bgElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToCommunity(BuildContext context, String communityId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityScreen(communityId: communityId),
      ),
    );
  }
  void _goToProfile(BuildContext context) {}
}
