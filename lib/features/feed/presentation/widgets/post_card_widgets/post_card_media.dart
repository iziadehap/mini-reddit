import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/post_images_carousel.dart';

class PostCardMedia extends StatelessWidget {
  final FeedPostModel post;

  const PostCardMedia({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.images != null && post.images!.isNotEmpty) {
      return _buildImageContent(context);
    } else if (post.postType == 'link' && post.linkUrl != null) {
      return _buildLinkContent(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageContent(BuildContext context) {
    final urls = post.images!
        .map((e) => e.imageUrl)
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: PostImagesCarousel(imageUrls: urls),
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
}
