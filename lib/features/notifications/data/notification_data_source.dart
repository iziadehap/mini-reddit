// notification_data_source.dart

import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/failure.dart';
import 'package:mini_reddit_v2/core/models/notification.dart';
import 'package:mini_reddit_v2/core/models/success.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<NotificationModel>> getNotifications({
    required int p_offset,
    required int p_limit,
  }) async {
    final response = await _supabase.rpc(
      'get_notifications',
      params: {
        'p_user_id': _supabase.auth.currentUser!.id,
        'p_limit': p_limit,
        'p_offset': p_offset,
      },
    );

    return (response as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<Either<Failure, SuccessModel>> markAsRead(
    String notificationId,
  ) async {
    try {
      await _supabase.rpc(
        'mark_notification_read',
        params: {
          'p_notification_id': notificationId,
          'p_user_id': _supabase.auth.currentUser!.id,
        },
      );
      return right(
        SuccessModel(message: 'Notification marked as read', success: true),
      );
    } catch (e) {
      return left(
        ServerFailure(message: 'Failed to mark notification as read'),
      );
    }
  }

  Future<Either<Failure, SuccessModel>> markAllAsRead() async {
    try {
      await _supabase.rpc(
        'mark_all_as_read',
        params: {'p_user_id': _supabase.auth.currentUser!.id},
      );
      return right(
        SuccessModel(
          message: 'All notifications marked as read',
          success: true,
        ),
      );
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, SuccessModel>> removeNotification(
    String notificationId,
  ) async {
    try {
      await _supabase.rpc(
        'remove_notification',
        params: {
          'p_notification_id': notificationId,
          'p_user_id': _supabase.auth.currentUser!.id,
        },
      );
      return right(
        SuccessModel(message: 'Notification removed', success: true),
      );
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
