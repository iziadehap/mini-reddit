// lib/core/constants/reddit_constants.dart
import 'dart:ui';

class RedditConstants {
  // Colors
  static const Color orange = Color(0xFFFF4500);
  static const Color orangeLight = Color(0xFFFF571F);
  static const Color upvote = Color(0xFFFF4500);
  static const Color downvote = Color(0xFF7193FF);
  static const Color bannerColor = Color(0xFF0079D3);
  static const Color darkSurface = Color(0xFF1A1A1B);

  // Spacing
  static const double cardSpacing = 8.0;
  static const double cardPadding = 12.0;
  static const double avatarRadius = 16.0;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 200);
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
