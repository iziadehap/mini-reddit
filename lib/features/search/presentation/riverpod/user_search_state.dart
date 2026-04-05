import 'package:mini_reddit_v2/core/models/models.dart';

class UserSearchState {
  final List<UserProfileModel> users;
  final bool isLoading;
  final String? error;
  final bool isEnd;
  final bool isLoadMore;

  UserSearchState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.isEnd = false,
    this.isLoadMore = false,
  });

  UserSearchState copyWith({
    List<UserProfileModel>? users,
    bool? isLoading,
    String? error,
    bool? isEnd,
    bool? isLoadMore,
    bool clearUsers = false,
  }) {
    return UserSearchState(
      users: clearUsers ? [] : (users ?? this.users),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEnd: isEnd ?? this.isEnd,
      isLoadMore: isLoadMore ?? this.isLoadMore,
    );
  }
}
