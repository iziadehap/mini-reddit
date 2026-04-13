import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/failure.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/search/data/user_search_data_source.dart';
import 'package:mini_reddit_v2/features/search/domain/user_search_repo.dart';

class UserSearchRepoImpl implements UserSearchRepo {
  final UserSearchDataSource _dataSource;

  UserSearchRepoImpl(this._dataSource);

  @override
  Future<Either<Failure, List<UserProfileModel>>> searchUsers({
    required String query,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final users = await _dataSource.searchUsers(
        query: query,
        offset: offset,
        limit: limit,
      );
      return Right(users);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
