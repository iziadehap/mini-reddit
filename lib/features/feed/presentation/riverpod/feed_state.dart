import 'package:mini_reddit_v2/core/models/models.dart';

class FeedState {
  final List<FeedPostModel>? feed;
  final bool isLoading;
  final String? error;
  final bool isFirstLoad;
  final bool isLoadMore;
  final bool isEnd;

  // Feed parameters
  final FeedType feedType;
  final TopFeedTimeframe timeframe;
  final String? searchQuery;
  final String? targetUserId;

  final String? selectedCommunityName;

  FeedState({
    this.feed,
    this.isLoading = false,
    this.error,
    this.isFirstLoad = false,
    this.isLoadMore = false,
    this.isEnd = false,
    this.feedType = FeedType.hot,
    this.timeframe = TopFeedTimeframe.day,
    this.searchQuery,
    this.targetUserId,
    this.selectedCommunityName,
  });

  FeedState copyWith({
    List<FeedPostModel>? feed,
    bool? isLoading,
    String? error,
    bool? isFirstLoad,
    bool? isLoadMore,
    bool? isEnd,
    FeedType? feedType,
    TopFeedTimeframe? timeframe,
    String? searchQuery,
    String? targetUserId,
    String? selectedCommunityName,
    bool clearSelectedCommunityName = false,
    bool clearFeed = false,
  }) {
    return FeedState(
      feed: clearFeed ? [] : (feed ?? this.feed),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      isEnd: isEnd ?? this.isEnd,
      feedType: feedType ?? this.feedType,
      timeframe: timeframe ?? this.timeframe,
      searchQuery: searchQuery ?? this.searchQuery,
      targetUserId: targetUserId ?? this.targetUserId,
      selectedCommunityName: clearSelectedCommunityName
          ? null
          : (selectedCommunityName ?? this.selectedCommunityName),
    );
  }

  factory FeedState.initial() => FeedState(
        feed: [],
        isLoading: false,
        error: null,
        isFirstLoad: true,
        isLoadMore: false,
        isEnd: false,
        feedType: FeedType.popular,
        timeframe: TopFeedTimeframe.day,
        selectedCommunityName: null,
        communities: [],
        userCommunities: [],
        isCommunitiesLoading: false,
        communitiesError: null,
      );
}
