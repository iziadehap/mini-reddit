import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/notifications/data/notification_data_source.dart';
import 'package:mini_reddit_v2/features/notifications/data/notification_impl.dart';

// Placeholder Notifications Provider
final notificationsProvider =
    StateNotifierProvider<
      NotificationsProvider,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      return NotificationsProvider(NotificationImpl(NotificationDataSource()));
    });

class NotificationsProvider
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationImpl _notificationImpl;
  NotificationsProvider(this._notificationImpl)
    : super(const AsyncValue.loading()) {
    getNotification();
  }

  void getNotification() async {
    setLoading();

    final data = await _notificationImpl.getNotifications(
      p_offset: 0,
      p_limit: 10,
    );

    data.fold(
      (failure) {
        setError(failure.message);
      },
      (success) {
        setSuccess(success);
      },
    );
  }

  void markAllAsRead() async {
    final currentNotifications = state.value ?? [];

    final result = await _notificationImpl.markAllAsRead();

    result.fold(
      (failure) {
        setError(failure.message);
      },
      (success) {
        final updatedNotifications = currentNotifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
        setSuccess(updatedNotifications);
      },
    );
  }

  void markAsRead(String id) async {
    final currentNotifications = state.value ?? [];

    final result = await _notificationImpl.markAsRead(notificationId: id);

    result.fold(
      (failure) {
        setError(failure.message);
      },
      (success) {
        final updatedNotifications = currentNotifications
            .map(
              (notification) => notification.id == id
                  ? notification.copyWith(isRead: true)
                  : notification,
            )
            .toList();
        setSuccess(updatedNotifications);
      },
    );
  }

  void removeNotification(String id) async {
    final currentNotifications = state.value ?? [];

    final result = await _notificationImpl.removeNotification(
      notificationId: id,
    );

    result.fold(
      (failure) {
        setError(failure.message);
      },
      (success) {
        final updatedNotifications = currentNotifications
            .where((notification) => notification.id != id)
            .toList();
        setSuccess(updatedNotifications);
      },
    );
  }

  void removeAllNotifications() async {
    final result = await _notificationImpl.removeAllNotifications();

    result.fold(
      (failure) {
        setError(failure.message);
      },
      (success) {
        setSuccess([]);
      },
    );
  }

  void undoRemove(String id) {
    getNotification();
  }

  // helper

  void setLoading() {
    state = AsyncValue.loading();
  }

  void setError(String error) {
    state = AsyncValue.error(error, StackTrace.current);
  }

  void setSuccess(List<NotificationModel> notifications) {
    state = AsyncValue.data(notifications);
  }
}
