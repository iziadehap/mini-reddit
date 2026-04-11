import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';
import 'post_card_share_button.dart';

class PostCardFooter extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final Future<bool> Function()? onSave;

  const PostCardFooter({
    super.key,
    required this.post,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Row(
        children: [
          PostCardVoteButtons(
            post: post,
            onUpvote: onUpvote,
            onDownvote: onDownvote,
          ),
          const SizedBox(width: 12),
          PostCardCommentButton(post: post, onComment: onComment),
          const SizedBox(width: 12),
          PostCardSaveButton(post: post, onSave: onSave),
          const Spacer(),
          PostCardShareButton(post: post, onShare: onShare),
        ],
      ),
    );
  }
}

class PostCardVoteButtons extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;

  const PostCardVoteButtons({
    super.key,
    required this.post,
    this.onUpvote,
    this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
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
            context: context,
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
            context: context,
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
    required BuildContext context,
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
}

class PostCardCommentButton extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onComment;

  const PostCardCommentButton({super.key, required this.post, this.onComment});

  @override
  Widget build(BuildContext context) {
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
}

class PostCardSaveButton extends StatelessWidget {
  final FeedPostModel post;
  final Future<bool> Function()? onSave;

  const PostCardSaveButton({super.key, required this.post, this.onSave});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 34,
      decoration: BoxDecoration(
        color: tokens.cardVoteBar,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LikeButton(
        isLiked: post.isSaved,
        onTap: (isLiked) async {
          await onSave?.call();
          return !isLiked;
        },
        size: 18,
        likeBuilder: (bool isLiked) {
          return Icon(
            Icons.bookmark,
            color: isLiked ? tokens.brandOrange : Colors.grey,
            size: 18,
          );
        },
        circleColor: CircleColor(
          start: tokens.brandOrange,
          end: tokens.brandOrange,
        ),
        bubblesColor: BubblesColor(
          dotPrimaryColor: tokens.brandOrange,
          dotSecondaryColor: tokens.brandOrange,
        ),
      ),
    );
  }
}
