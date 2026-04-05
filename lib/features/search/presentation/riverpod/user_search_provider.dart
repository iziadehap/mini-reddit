import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/features/search/data/user_search_data_source.dart';
import 'package:mini_reddit_v2/features/search/data/user_search_repo_impl.dart';
import 'package:mini_reddit_v2/features/search/domain/user_search_repo.dart';
import 'package:mini_reddit_v2/features/search/presentation/riverpod/user_search_state.dart';

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, UserSearchState>((ref) {
  return UserSearchNotifier(
    userSearchRepo: UserSearchRepoImpl(UserSearchDataSource()),
  );
});

class UserSearchNotifier extends StateNotifier<UserSearchState> {
  final UserSearchRepo _userSearchRepo;
  String _currentQuery = '';
  Timer? _debounce;

  UserSearchNotifier({required UserSearchRepo userSearchRepo})
      : _userSearchRepo = userSearchRepo,
        super(UserSearchState());

  void searchUsers(String query) {
    _debounce?.cancel();

    _currentQuery = query.trim();

    if (_currentQuery.isEmpty) {
      state = state.copyWith(clearUsers: true, isEnd: false);
      return;
    }

    _fetchUsers(offset: 0);
  }

  void loadMore() {
    if (state.isLoading || state.isEnd || state.isLoadMore) return;
    if (state.users.isEmpty) return;

    _fetchUsers(offset: state.users.length);
  }

  Future<void> _fetchUsers({required int offset}) async {
    if (offset == 0) {
      state = state.copyWith(isLoading: true, isEnd: false, clearUsers: true);
    } else {
      state = state.copyWith(isLoadMore: true);
    }

    final result = await _userSearchRepo.searchUsers(
      query: _currentQuery,
      offset: offset,
      limit: 20,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadMore: false,
          error: failure.message,
        );
      },
      (users) {
        state = state.copyWith(
          users: offset == 0 ? users : [...state.users, ...users],
          isLoading: false,
          isLoadMore: false,
          isEnd: users.length < 20,
          error: null,
        );
      },
    );
  }
}
