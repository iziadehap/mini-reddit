// lib/core/utils/time_formatter.dart
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';

class TimeFormatter {
  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}${StringConstants.yearAgo}';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}${StringConstants.monthAgo}';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays}${StringConstants.dayAgo}';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}${StringConstants.hourAgo}';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${StringConstants.minuteAgo}';
    }
    return StringConstants.justNow;
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatPostCount(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M posts';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K posts';
    } else if (number == 1) {
      return '1 post';
    }
    return '$number posts';
  }
}
