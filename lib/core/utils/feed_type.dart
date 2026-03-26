import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';
import 'package:remixicon/remixicon.dart';

class FeedTypeUtils {
  static List<String> feedType = ["Hot", "New", "Top", "Best", "Popular"];
  // user iconPlus

  static List<IconData> feedTypeIcon = [
    Remix.fire_line, // Hot/Best
    Remix.newspaper_line, // New
    Remix.rocket_line, // Rising
    Remix.bar_chart_line, // Top
    Remix.flashlight_line, // Controversial
  ];
  static List<String> timeFrame = ["Day", "Week", "Month", "Year", "All Time"];

  static FeedType getTypeForIndex(String index) {
    switch (index) {
      case "Hot":
        return FeedType.hot;
      case "New":
        return FeedType.newFeed;
      case "Top":
        return FeedType.top;
      case "Best":
        return FeedType.best;
      case "Popular":
        return FeedType.popular;
      default:
        return FeedType.hot;
    }
  }

  static String getLabelForTimeframe(TopFeedTimeframe timeframe) {
    switch (timeframe) {
      case TopFeedTimeframe.day:
        return 'Today';
      case TopFeedTimeframe.week:
        return 'This Week';
      case TopFeedTimeframe.month:
        return 'This Month';
      case TopFeedTimeframe.year:
        return 'This Year';
      case TopFeedTimeframe.all:
        return 'All Time';
    }
  }
}
