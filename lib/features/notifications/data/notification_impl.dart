import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/failure.dart';
import 'package:mini_reddit_v2/core/models/notification.dart';
import 'package:mini_reddit_v2/core/models/success.dart';
import 'package:mini_reddit_v2/features/notifications/data/notification_data_source.dart';
import 'package:mini_reddit_v2/features/notifications/domain/notification_repo.dart';

class NotificationImpl implements NotificationRepo {
  final NotificationDataSource _notificationDataSource;
  NotificationImpl(this._notificationDataSource);

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required int p_offset,
    required int p_limit,
  }) async {
    try {
      final data = await _notificationDataSource.getNotifications(
        p_offset: p_offset,
        p_limit: p_limit,
      );

      debugPrint("get Notification success ${data.length.toString()}");

      return right(data);
    } catch (e) {
      debugPrint('error when get Notification ${e.toString()}');
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> markAsRead({
    required String notificationId,
  }) {
    return _notificationDataSource.markAsRead(notificationId);
  }

  @override
  Future<Either<Failure, SuccessModel>> markAllAsRead() {
    return _notificationDataSource.markAllAsRead();
  }

  @override
  Future<Either<Failure, SuccessModel>> removeNotification({
    required String notificationId,
  }) {
    return _notificationDataSource.removeNotification(notificationId);
  }

}
