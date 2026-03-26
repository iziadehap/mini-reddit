import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/notifications/presentation/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: () {}),
        ],
      ),
      body: notificationsState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              message: 'Check back later for notifications!',
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: notification.actorAvatarUrl != null
                      ? NetworkImage(notification.actorAvatarUrl!)
                      : null,
                  child: notification.actorAvatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: 'u/${notification.actorUsername} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: _getNotificationText(notification.type)),
                    ],
                  ),
                ),
                subtitle: Text(
                  DateFormat.yMMMd().format(notification.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: !notification.isRead
                    ? const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.blue,
                      )
                    : null,
                onTap: () {},
              );
            },
          );
        },
        loading: () => ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SkeletonLoader(height: 60),
          ),
        ),
        error: (error, stack) =>
            ErrorWidgetCustom(message: 'Failed to load notifications: $error'),
      ),
    );
  }

  String _getNotificationText(String type) {
    switch (type) {
      case 'like':
        return 'liked your post';
      case 'comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      default:
        return 'sent a notification';
    }
  }
}
