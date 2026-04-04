// lib/features/feed/presentation/widgets/empty_feed_widget.dart
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';

class EmptyFeedWidget extends StatelessWidget {
  final VoidCallback onFindCommunities;
  final VoidCallback onExplorePopular;
  final Function(String) onCommunityTap;

  const EmptyFeedWidget({
    super.key,
    required this.onFindCommunities,
    required this.onExplorePopular,
    required this.onCommunityTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedIcon(),
                const SizedBox(height: 32),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(isDark),
                const SizedBox(height: 40),
                _buildPrimaryButton(),
                const SizedBox(height: 16),
                _buildSecondaryButton(),
                const SizedBox(height: 32),
                _buildTrendingCommunities(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [RedditConstants.orange, RedditConstants.orangeLight],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.reddit, size: 60, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AssetsUtils.emojiCrying, width: 32, height: 32),
        const SizedBox(width: 12),
        const Text(
          'Your feed is empty',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      StringConstants.emptyFeedSubtitle,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: onFindCommunities,
      style: ElevatedButton.styleFrom(
        backgroundColor: RedditConstants.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size(240, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 20),
          SizedBox(width: 8),
          Text(
            StringConstants.findCommunities,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton(
      onPressed: onExplorePopular,
      style: OutlinedButton.styleFrom(
        foregroundColor: RedditConstants.orange,
        side: const BorderSide(color: RedditConstants.orange, width: 1.5),
        minimumSize: const Size(240, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: const Text(
        StringConstants.explorePopular,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTrendingCommunities(bool isDark) {
    final trendingCommunities = [
      {'name': 'r/AskReddit', 'icon': Icons.chat},
      {'name': 'r/gaming', 'icon': Icons.sports_esports},
      {'name': 'r/aww', 'icon': Icons.pets},
      {'name': 'r/memes', 'icon': Icons.emoji_emotions},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.trendingCommunities,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trendingCommunities.map((community) {
            return _buildCommunityChip(
              community['name'] as String,
              community['icon'] as IconData,
              isDark,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommunityChip(String label, IconData icon, bool isDark) {
    return ActionChip(
      onPressed: () => onCommunityTap(label.replaceFirst('r/', '')),
      avatar: Icon(icon, size: 16, color: RedditConstants.orange),
      label: Text(label),
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
