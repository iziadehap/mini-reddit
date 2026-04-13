import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class PostCardFlair extends StatelessWidget {
  final FeedPostModel post;

  const PostCardFlair({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
          color: flairColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: flairColor.withValues(alpha: 0.3), width: 0.5),
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
}
