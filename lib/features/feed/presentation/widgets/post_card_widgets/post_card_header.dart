import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';

class PostCardHeader extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onDelete;
  final void Function(String)? onCommunityTap;
  final void Function(String)? onUserTap;

  const PostCardHeader({
    super.key,
    required this.post,
    this.onDelete,
    this.onCommunityTap,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
      child: Row(
        children: [
          _buildAvatar(context, tokens),
          const SizedBox(width: 8),
          Expanded(child: _buildPostInfo(context)),
          if (onDelete != null) _buildMoreButton(context, tokens),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, RedditTokens tokens) {
    String? avatarUrl = post.communityName.isNotEmpty
        ? post.communityImageUrl
        : post.authorAvatarUrl;

    return GestureDetector(
      onTap: () {
        if (post.communityName.isNotEmpty) {
          onCommunityTap?.call(post.communityId);
        } else if (post.authorId.isNotEmpty) {
          onUserTap?.call(post.authorId);
        }
      },
      child: CircleAvatar(
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
      ),
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
                onTap: () => onCommunityTap?.call(post.communityId),
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
            InkWell(
              onTap: () => onUserTap?.call(post.authorId),
              child: Text('u/${post.authorUsername}', style: typo.postMeta),
            ),
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

  Widget _buildMoreButton(BuildContext context, RedditTokens tokens) {
    return IconButton(
      icon: Icon(Icons.more_horiz, size: 20, color: tokens.textSecondary),
      onPressed: () => _showPostMenu(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 20,
      tooltip: 'More options',
    );
  }

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
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Post',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined, color: tokens.textSecondary),
              title: Text('Report Post', style: context.rTypo.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _showReportSnackbar(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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
}
