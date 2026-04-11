// lib/core/constants/reddit_constants.dart
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class RedditConstants {
  // Use app_theme_v2 tokens for theme values
  // Access via: context.tokens.brandOrange, etc.

  // Spacing (from AppSpacing tokens)
  static const double cardSpacing = AppSpacing.sm; // 8.0
  static const double cardPadding = AppSpacing.md; // 12.0
  static const double avatarRadius = 16.0;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 200);

  // Deep links
  static const String postDeepLinkPrefix = 'mini-reddit://post/';
  static const String communityDeepLinkPrefix = 'mini-reddit://community/';
}

// Theme constants using app_theme_v2
abstract final class ThemeConstants {
  // Border radius
  static const double radiusXs = AppRadius.xs;
  static const double radiusSm = AppRadius.sm;
  static const double radiusMd = AppRadius.md;
  static const double radiusLg = AppRadius.lg;
  static const double radiusFull = AppRadius.full;

  // Spacing shortcuts
  static const double spacingXxs = AppSpacing.xxs;
  static const double spacingXs = AppSpacing.xs;
  static const double spacingSm = AppSpacing.sm;
  static const double spacingMd = AppSpacing.md;
  static const double spacingLg = AppSpacing.lg;
  static const double spacingXl = AppSpacing.xl;
  static const double spacingXxl = AppSpacing.xxl;
  static const double spacingXxxl = AppSpacing.xxxl;
  static const double spacingHuge = AppSpacing.huge;
}

// lib/core/constants/string_constants.dart
class StringConstants {
  // Feed messages
  static const String emptyFeedTitle = 'Your feed is empty';
  static const String emptyFeedSubtitle =
      'Join some communities to see their posts here.\nThe best conversations are waiting for you!';
  static const String findCommunities = 'Find Communities';
  static const String explorePopular = 'Explore Popular Posts';
  static const String trendingCommunities = 'TRENDING COMMUNITIES';

  // Community messages
  static const String noCommunities = 'No communities yet';
  static const String noResultsFound = 'No results found';
  static const String tryDifferentSearch = 'Try a different search term';
  static const String createCommunity = 'Create Community';
  static const String createCommunityHint = 'Create a community';

  // Post actions
  static const String upvote = 'Upvote';
  static const String downvote = 'Downvote';
  static const String comments = 'Comments';
  static const String share = 'Share';
  static const String delete = 'Delete';
  static const String deletePost = 'Delete Post';
  static const String deleteConfirmation =
      'Are you sure you want to delete this post?';
  static const String cancel = 'Cancel';

  // Time formats
  static const String justNow = 'just now';
  static const String yearAgo = 'y';
  static const String monthAgo = 'mo';
  static const String dayAgo = 'd';
  static const String hourAgo = 'h';
  static const String minuteAgo = 'm';
}
