import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class PostCardContent extends StatelessWidget {
  final FeedPostModel post;

  const PostCardContent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final typo = context.rTypo;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
}
