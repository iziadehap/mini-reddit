import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

// Placeholder Notifications Provider
final notificationsProvider =
    StateProvider<AsyncValue<List<NotificationModel>>>((ref) {
      return const AsyncValue.loading();
    });

// Placeholder Notification Actions
Future<void> markAsRead(String notificationId) async {}
Future<void> clearNotifications() async {}
