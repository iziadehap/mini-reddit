import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

class PostVoteButton extends StatelessWidget {
  final PostDetailsModel post;
  final Color pillColor;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostVoteButton({
    super.key,
    required this.post,
    required this.pillColor,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Upvote / Downvote Pill
        Container(
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionIcon(
                icon: post.userVote == 1
                    ? Icons.arrow_upward
                    : Icons.arrow_upward_outlined,
                color: post.userVote == 1
                    ? Colors.deepOrange
                    : theme.iconTheme.color,
                onTap: onUpvote,
                isLeft: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${post.score}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: post.userVote == 1
                        ? Colors.deepOrange
                        : post.userVote == -1
                        ? Colors.indigo
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildActionIcon(
                icon: post.userVote == -1
                    ? Icons.arrow_downward
                    : Icons.arrow_downward_outlined,
                color: post.userVote == -1
                    ? Colors.indigo
                    : theme.iconTheme.color,
                onTap: onDownvote,
                isRight: true,
              ),
            ],
          ),
        ),

        // Comments Pill
        _buildPillButton(
          icon: Icons.chat_bubble_outline,
          label: '${post.commentsCount}',
          onTap: onComment,
          color: pillColor,
        ),

        // Share Pill
        _buildPillButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: onShare ?? () {}, // لو مش موجود، يعمل nothing
          color: pillColor,
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color? color,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== نسخة مصغرة للتعليقات ==========
class CommentVoteButton extends StatelessWidget {
  final CommentModel comment;
  final Color pillColor;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final bool isSmall;
  final bool isDisabled;

  const CommentVoteButton({
    super.key,
    required this.comment,
    required this.pillColor,
    this.onUpvote,
    this.onDownvote,
    this.isSmall = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upvote
          InkWell(
            onTap: isDisabled ? null : onUpvote,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 6 : 8,
                vertical: isSmall ? 2 : 4,
              ),
              child: Icon(
                comment.userVote == 1
                    ? Icons.arrow_upward
                    : Icons.arrow_upward_outlined,
                size: isSmall ? 16 : 18,
                color: comment.userVote == 1
                    ? Colors.deepOrange
                    : Colors.grey[600],
              ),
            ),
          ),

          // Score
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 2 : 4),
            child: Text(
              '${comment.score}',
              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: comment.userVote == 1
                    ? Colors.deepOrange
                    : comment.userVote == -1
                    ? Colors.indigo
                    : Colors.grey[700],
              ),
            ),
          ),

          // Downvote
          InkWell(
            onTap: isDisabled ? null : onDownvote,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 6 : 8,
                vertical: isSmall ? 2 : 4,
              ),
              child: Icon(
                comment.userVote == -1
                    ? Icons.arrow_downward
                    : Icons.arrow_downward_outlined,
                size: isSmall ? 16 : 18,
                color: comment.userVote == -1
                    ? Colors.indigo
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
