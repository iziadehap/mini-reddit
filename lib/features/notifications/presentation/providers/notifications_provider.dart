import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Keep track of removed items for undo functionality
  final Map<String, NotificationModel> _removedCache = {};

  // Pagination state
  int _currentOffset = 0;
  static const int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  NotificationsProvider(this._notificationImpl)
    : super(const AsyncValue.loading()) {
    getNotification();
  }

  // Getters for pagination
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  void getNotification() async {
    _currentOffset = 0;
    _hasMore = true;
    setLoading();

    final data = await _notificationImpl.getNotifications(
      p_offset: 0,
      p_limit: _limit,
    );

    data.fold(
      (failure) {
        setError(failure.message);
      },
      (success) {
        _hasMore = success.length >= _limit;
        setSuccess(success);
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    final currentData = state.value ?? [];
    _isLoadingMore = true;

    // Notify listeners about loading state without clearing data
    state = AsyncValue.data(currentData);

    final data = await _notificationImpl.getNotifications(
      p_offset: _currentOffset + _limit,
      p_limit: _limit,
    );

    _isLoadingMore = false;

    data.fold(
      (failure) {
        // Keep existing data on error, just show error state
        state = AsyncValue.data(currentData);
      },
      (success) {
        _currentOffset += _limit;
        _hasMore = success.length >= _limit;
        setSuccess([...currentData, ...success]);
      },
    );
  }

  Future<void> refresh() async {
    _removedCache.clear();
    getNotification();
  }

  void markAllAsRead() async {
    final currentNotifications = state.value ?? [];

    // Optimistic update
    final optimisticUpdate = currentNotifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    setSuccess(optimisticUpdate);

    final result = await _notificationImpl.markAllAsRead();

    result.fold(
      (failure) {
        // Revert on failure
        setSuccess(currentNotifications);
        setError(failure.message);
      },
      (success) {
        // Already updated optimistically
      },
    );
  }

  void markAsRead(String id) async {
    final currentNotifications = state.value ?? [];

    // Optimistic update
    final optimisticUpdate = currentNotifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    setSuccess(optimisticUpdate);

    final result = await _notificationImpl.markAsRead(notificationId: id);

    result.fold(
      (failure) {
        // Revert on failure
        setSuccess(currentNotifications);
        setError(failure.message);
      },
      (success) {
        // Already updated
      },
    );
  }

  void removeNotification(String id) async {
    final currentNotifications = state.value ?? [];
    final notificationToRemove = currentNotifications.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Notification not found'),
    );

    // Cache for undo
    _removedCache[id] = notificationToRemove;

    // Optimistic update
    final optimisticUpdate = currentNotifications
        .where((n) => n.id != id)
        .toList();
    setSuccess(optimisticUpdate);

    final result = await _notificationImpl.removeNotification(
      notificationId: id,
    );

    result.fold(
      (failure) {
        // Revert on failure
        _removedCache.remove(id);
        setSuccess(currentNotifications);
        setError(failure.message);
      },
      (success) {
        // Keep in cache for undo duration (optional: auto-clear after delay)
      },
    );
  }

  // void removeAllNotifications() async {
  //   final currentNotifications = state.value ?? [];

  //   // Optimistic update
  //   setSuccess([]);

  //   final result = await _notificationImpl.removeAllNotifications();

  //   result.fold(
  //     (failure) {
  //       // Revert on failure
  //       setSuccess(currentNotifications);
  //       setError(failure.message);
  //     },
  //     (success) {
  //       _removedCache.clear();
  //     },
  //   );
  // }

  void undoRemove(String id) {
    final removedNotification = _removedCache.remove(id);
    if (removedNotification == null) return;

    final currentNotifications = state.value ?? [];

    // Insert back at original position or append
    final updatedList = [...currentNotifications, removedNotification];
    // Sort by date to maintain order
    updatedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setSuccess(updatedList);
  }

  // Helper methods
  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setError(String error) {
    state = AsyncValue.error(error, StackTrace.current);
  }

  void setSuccess(List<NotificationModel> notifications) {
    state = AsyncValue.data(notifications);
  }
}
