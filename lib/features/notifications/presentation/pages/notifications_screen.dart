import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';

// ─────────────────────────────────────────────────────────
// Filter enum
// ─────────────────────────────────────────────────────────
enum NotificationFilter { all, upvotes, comments, follows, mentions }

extension NotificationFilterLabel on NotificationFilter {
  String get label {
    switch (this) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.upvotes:
        return 'Upvotes';
      case NotificationFilter.comments:
        return 'Comments';
      case NotificationFilter.follows:
        return 'Follows';
      case NotificationFilter.mentions:
        return 'Mentions';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationFilter.all:
        return Icons.notifications_outlined;
      case NotificationFilter.upvotes:
        return Icons.arrow_upward_rounded;
      case NotificationFilter.comments:
        return Icons.chat_bubble_outline_rounded;
      case NotificationFilter.follows:
        return Icons.person_add_outlined;
      case NotificationFilter.mentions:
        return Icons.alternate_email_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────
// Notifications Screen
// ─────────────────────────────────────────────────────────
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _activeFilter = NotificationFilter.all;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(notificationsProvider.notifier).loadMoreNotifications();
    }
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> notifications) {
    if (_activeFilter == NotificationFilter.all) return notifications;

    final types = switch (_activeFilter) {
      NotificationFilter.upvotes => ['post_upvote', 'comment_upvote'],
      NotificationFilter.comments => ['reply', 'post_comment'],
      NotificationFilter.follows => ['follow'],
      NotificationFilter.mentions => ['mention'],
      NotificationFilter.all => <String>[],
    };

    return notifications.where((n) => types.contains(n.type)).toList();
  }

  // Group notifications by time period
  Map<String, List<NotificationModel>> _groupByTime(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<NotificationModel>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (final notification in notifications) {
      final date = notification.createdAt;
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        groups['Today']!.add(notification);
      } else if (dateOnly == yesterday) {
        groups['Yesterday']!.add(notification);
      } else if (now.difference(date).inDays < 7) {
        groups['This Week']!.add(notification);
      } else {
        groups['Earlier']!.add(notification);
      }
    }

    return groups..removeWhere((key, value) => value.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: tokens.bgPage,
      appBar: AppBar(
        backgroundColor: tokens.bgSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: tokens.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          _UnreadBadge(
            count: notificationsState.when(
              data: (list) => list.where((n) => !n.isRead).length,
              loading: () => 0,
              error: (_, __) => 0,
            ),
          ),
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: tokens.textSecondary),
            tooltip: 'Mark all as read',
            onPressed: () => _handleMarkAllRead(context),
          ),
          // IconButton(
          //   icon: Icon(Icons.more_vert_rounded, color: tokens.textSecondary),
          // tooltip:
          //       'Mark all as read',

          //     onPressed: () {
          //       _handleMarkAllRead(context);
          //     },
          // ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _FilterChipRow(
            activeFilter: _activeFilter,
            onFilterChanged: (f) => setState(() => _activeFilter = f),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        color: tokens.brandOrange,
        backgroundColor: tokens.bgSurface,
        child: notificationsState.when(
          data: (notifications) {
            final filtered = _applyFilter(notifications);

            if (filtered.isEmpty) {
              return _EmptyState(
                filter: _activeFilter,
                onRefresh: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
              );
            }

            final groups = _groupByTime(filtered);

            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                for (final entry in groups.entries) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      label: entry.key,
                      count: entry.key == 'Today'
                          ? entry.value.where((n) => !n.isRead).length
                          : null,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final notification = entry.value[index];
                      final isLast = index == entry.value.length - 1;

                      return _NotificationTile(
                        key: ValueKey(notification.id),
                        notification: notification,
                        onDismissed: () =>
                            _handleDismiss(context, notification),
                        onTap: () => _handleTap(context, notification),
                        isLast: isLast,
                      );
                    }, childCount: entry.value.length),
                  ),
                ],
                // Loading indicator for pagination
                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final isLoadingMore = ref
                          .watch(notificationsProvider.notifier)
                          .isLoadingMore;
                      return isLoadingMore
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tokens.brandOrange,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
              ],
            );
          },
          loading: () => _LoadingList(tokens: tokens),
          error: (error, stack) => ErrorWidgetCustom(
            message: 'Failed to load notifications: $error',
            onRetry: () =>
                ref.read(notificationsProvider.notifier).getNotification(),
          ),
        ),
      ),
    );
  }

  // ── Handlers ─────────────────────────────────────────────

  void _handleMarkAllRead(BuildContext context) {
    final tokens = context.tokens;
    ref.read(notificationsProvider.notifier).markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: tokens.success, size: 20),
            const SizedBox(width: 12),
            Text(
              'All notifications marked as read',
              style: TextStyle(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: tokens.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDismiss(BuildContext context, NotificationModel notification) {
    final tokens = context.tokens;
    ref
        .read(notificationsProvider.notifier)
        .removeNotification(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification removed',
          style: TextStyle(color: tokens.textPrimary),
        ),
        backgroundColor: tokens.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: tokens.brandOrange,
          onPressed: () => ref
              .read(notificationsProvider.notifier)
              .undoRemove(notification.id),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, NotificationModel notification) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    if (notification.postId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PostDetailsScreen(postId: notification.postId!),
        ),
      );
    }
  }

  // void _showMoreOptions(BuildContext context) {
  //   final tokens = context.tokens;
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: tokens.bgSurface,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (ctx) => SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           _BottomSheetHandle(tokens: tokens),
  //           ListTile(
  //             leading: Icon(Icons.done_all_rounded, color: tokens.brandOrange),
  //             title: Text(
  //               'Mark all as read',
  //               style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600),
  //             ),
  //             onTap: () {
  //               Navigator.pop(ctx);
  //               _handleMarkAllRead(context);
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.delete_sweep_outlined, color: tokens.error),
  //             title: Text(
  //               'Clear all notifications',
  //               style: TextStyle(color: tokens.error, fontWeight: FontWeight.w600),
  //             ),
  //             onTap: () {
  //               Navigator.pop(ctx);
  //               _confirmClearAll(context);
  //             },
  //           ),
  //           const SizedBox(height: 16),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _confirmClearAll(BuildContext context) {
  //   final tokens = context.tokens;
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       backgroundColor: tokens.bgElevated,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Text(
  //         'Clear all notifications?',
  //         style: TextStyle(
  //           color: tokens.textPrimary,
  //           fontWeight: FontWeight.w700,
  //           fontSize: 18,
  //         ),
  //       ),
  //       content: Text(
  //         'This action cannot be undone. All notifications will be permanently removed.',
  //         style: TextStyle(color: tokens.textSecondary, fontSize: 14),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: Text(
  //             'Cancel',
  //             style: TextStyle(color: tokens.textSecondary, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //         // FilledButton(
  //         //   onPressed: () {
  //         //     Navigator.pop(ctx);
  //         //     ref.read(notificationsProvider.notifier).removeAllNotifications();
  //         //   },
  //         //   style: FilledButton.styleFrom(
  //         //     backgroundColor: tokens.error,
  //         //     foregroundColor: Colors.white,
  //         //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         //   ),
  //         //   child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.w600)),
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}

// ─────────────────────────────────────────────────────────
// Unread Badge
// ─────────────────────────────────────────────────────────
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    final tokens = context.tokens;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: tokens.brandOrange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Loading List
// ─────────────────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  final dynamic tokens;

  const _LoadingList({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.bgSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SkeletonLoader(height: 48, width: 48, borderRadius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(height: 14, width: double.infinity),
                  const SizedBox(height: 8),
                  SkeletonLoader(height: 12, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Filter Chip Row
// ─────────────────────────────────────────────────────────
class _FilterChipRow extends StatelessWidget {
  final NotificationFilter activeFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  const _FilterChipRow({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        border: Border(bottom: BorderSide(color: tokens.divider, width: 1)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: NotificationFilter.values.length,
        itemBuilder: (context, index) {
          final filter = NotificationFilter.values[index];
          final isActive = filter == activeFilter;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: FilterChip(
              selected: isActive,
              showCheckmark: false,
              avatar: Icon(
                filter.icon,
                size: 16,
                color: isActive ? tokens.brandOrange : tokens.textSecondary,
              ),
              label: Text(filter.label),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? tokens.brandOrange : tokens.textSecondary,
              ),
              selectedColor: tokens.brandOrange.withOpacity(0.15),
              backgroundColor: tokens.bgElevated,
              side: BorderSide(
                color: isActive ? tokens.brandOrange : tokens.borderDefault,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onSelected: (_) => onFilterChanged(filter),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;

  const _SectionHeader({required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: tokens.textSecondary,
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tokens.brandOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final NotificationFilter filter;
  final VoidCallback onRefresh;

  const _EmptyState({required this.filter, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: tokens.bgElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(
              filter == NotificationFilter.all
                  ? Icons.notifications_none_rounded
                  : filter.icon,
              size: 48,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AssetsUtils.emojiCalmSmile, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                filter == NotificationFilter.all
                    ? 'No notifications yet'
                    : 'No ${filter.label.toLowerCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            filter == NotificationFilter.all
                ? 'Check back later for updates'
                : 'Try selecting a different filter',
            style: TextStyle(fontSize: 14, color: tokens.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (filter != NotificationFilter.all)
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Notification Tile
// ─────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDismissed;
  final VoidCallback onTap;
  final bool isLast;

  const _NotificationTile({
    super.key,
    required this.notification,
    required this.onDismissed,
    required this.onTap,
    this.isLast = false,
  });

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  String _getNotificationText() {
    switch (notification.type) {
      case 'post_upvote':
        return 'upvoted your post';
      case 'comment_upvote':
        return 'upvoted your comment';
      case 'reply':
        return 'replied to your comment';
      case 'post_comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you';
      default:
        return 'interacted with your content';
    }
  }

  Color _typeColor(BuildContext context) {
    final tokens = context.tokens;
    switch (notification.type) {
      case 'post_upvote':
      case 'comment_upvote':
        return tokens.upvote;
      case 'reply':
      case 'post_comment':
        return tokens.brandBlue;
      case 'follow':
        return const Color(0xFF9B59B6);
      case 'mention':
        return tokens.success;
      default:
        return tokens.voteNeutral;
    }
  }

  IconData _typeIcon() {
    switch (notification.type) {
      case 'post_upvote':
      case 'comment_upvote':
        return Icons.arrow_upward_rounded;
      case 'reply':
      case 'post_comment':
        return Icons.chat_bubble_rounded;
      case 'follow':
        return Icons.person_add_rounded;
      case 'mention':
        return Icons.alternate_email_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _typeColor(context);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: tokens.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDismissed(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: notification.isRead
              ? tokens.bgSurface
              : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: color.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotifAvatar(
                    notification: notification,
                    typeColor: color,
                    typeIcon: _typeIcon(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              fontFamily: 'IBMPlexSans',
                            ),
                            children: [
                              TextSpan(
                                text: 'u/${notification.actorUsername} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: notification.isRead
                                      ? tokens.textPrimary
                                      : color,
                                ),
                              ),
                              TextSpan(
                                text: _getNotificationText(),
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                  color: notification.isRead
                                      ? tokens.textSecondary
                                      : tokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: tokens.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(left: 12, top: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────
class _NotifAvatar extends StatelessWidget {
  final NotificationModel notification;
  final Color typeColor;
  final IconData typeIcon;

  const _NotifAvatar({
    required this.notification,
    required this.typeColor,
    required this.typeIcon,
  });

  String get _initials {
    final name = notification.actorUsername;
    if (name.isEmpty) return '?';
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: typeColor.withOpacity(0.15),
            backgroundImage: notification.actorAvatarUrl != null
                ? NetworkImage(notification.actorAvatarUrl!)
                : null,
            child: notification.actorAvatarUrl == null
                ? Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: typeColor,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: typeColor,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.bgSurface, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(typeIcon, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Bottom Sheet Handle
// ─────────────────────────────────────────────────────────
class _BottomSheetHandle extends StatelessWidget {
  final dynamic tokens;

  const _BottomSheetHandle({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: tokens.borderDefault,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
