enum TopFeedTimeframe {
  day('day'),
  week('week'),
  month('month'),
  year('year'),
  all('all');

  final String value;
  const TopFeedTimeframe(this.value);
}

enum FeedType { hot, newFeed, top, best, popular, user, community, search }
