import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/failure.dart';
import 'package:mini_reddit_v2/core/models/notification.dart';
import 'package:mini_reddit_v2/core/models/success.dart';

abstract class NotificationRepo {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required int p_offset,
    required int p_limit,
  });

  Future<Either<Failure, SuccessModel>> markAsRead({
    required String notificationId,
  });

  Future<Either<Failure, SuccessModel>> markAllAsRead();

  Future<Either<Failure, SuccessModel>> removeNotification({
    required String notificationId,
  });

  Future<Either<Failure, SuccessModel>> removeAllNotifications();
}
