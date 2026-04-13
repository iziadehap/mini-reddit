// lib/features/feed/presentation/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';
import 'package:mini_reddit_v2/features/profile/presentation/pages/user_profile_screen.dart';
import 'post_card_widgets/post_card_widgets.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final Future<bool> Function()? onSave;

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
            PostCardHeader(
              post: post,
              onDelete: onDelete,
              onCommunityTap: (id) => _goToCommunity(context, id),
              onUserTap: (id) => _goToProfile(context, id),
            ),
            PostCardFlair(post: post),
            PostCardContent(post: post),
            PostCardMedia(post: post),
            PostCardFooter(
              post: post,
              onUpvote: onUpvote,
              onDownvote: onDownvote,
              onComment: onComment,
              onShare: onShare,
              onSave: onSave,
            ),
          ],
        ),
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

  void _goToProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }
}
