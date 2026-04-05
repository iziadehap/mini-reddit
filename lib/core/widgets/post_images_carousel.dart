import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:photo_opener_view/photo_opener_view.dart';

/// Swipeable post images with dot indicators; tap opens [MediaViewer] gallery.
class PostImagesCarousel extends StatefulWidget {
  const PostImagesCarousel({
    super.key,
    required this.imageUrls,
    this.aspectRatio = 16 / 9,
    this.borderRadius = 12,
  });

  final List<String> imageUrls;
  final double aspectRatio;
  final double borderRadius;

  @override
  State<PostImagesCarousel> createState() => _PostImagesCarouselState();
}

class _PostImagesCarouselState extends State<PostImagesCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;
    final n = urls.length;
    final infinite = n > 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: n,
          options: CarouselOptions(
            aspectRatio: widget.aspectRatio,
            viewportFraction: 1,
            enableInfiniteScroll: infinite,
            enlargeCenterPage: false,
            padEnds: false,
            onPageChanged: (index, _) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                MediaViewer.openImageGallery(
                  context,
                  urls,
                  initialIndex: index,
                  showThumbnails: n > 1,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Image.network(
                  urls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, _, _) => Container(
                    color: tokens.bgElevated,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: tokens.textMuted,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: tokens.bgElevated,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tokens.brandOrange,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        if (n > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(n, (i) {
              final active = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: active
                      ? tokens.brandOrange
                      : tokens.textMuted.withValues(alpha: 0.35),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
