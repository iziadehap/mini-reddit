import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';

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

  // Community-related state
  final String? selectedCommunityName;
  final List<CommunityModel>? communities;
  final List<UserCommunityModel>? userCommunities;
  final bool isCommunitiesLoading;
  final String? communitiesError;

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
    this.communities,
    this.userCommunities,
    this.isCommunitiesLoading = false,
    this.communitiesError,
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
    List<CommunityModel>? communities,
    List<UserCommunityModel>? userCommunities,
    bool? isCommunitiesLoading,
    String? communitiesError,
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
      communities: communities ?? this.communities,
      userCommunities: userCommunities ?? this.userCommunities,
      isCommunitiesLoading: isCommunitiesLoading ?? this.isCommunitiesLoading,
      communitiesError: communitiesError ?? this.communitiesError,
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
