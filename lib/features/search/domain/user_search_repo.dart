import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

abstract class UserSearchRepo {
  Future<Either<Failure, List<UserProfileModel>>> searchUsers({
    required String query,
    int offset = 0,
    int limit = 20,
  });
}
