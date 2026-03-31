import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/core/widgets/skeleton_loader.dart';
import 'package:mini_reddit_v2/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/pages/post_details_screen.dart';
import 'package:mini_reddit_v2/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
// Filter enum
// ─────────────────────────────────────────────────────────
enum NotificationFilter { all, upvotes, comments, follows, mentions }

extension NotificationFilterLabel on NotificationFilter {
  String get label {
    switch (this) {
      case NotificationFilter.all:      return 'All';
      case NotificationFilter.upvotes:  return 'Upvotes';
      case NotificationFilter.comments: return 'Comments';
      case NotificationFilter.follows:  return 'Follows';
      case NotificationFilter.mentions: return 'Mentions';
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

  List<NotificationModel> _applyFilter(List<NotificationModel> notifications) {
    if (_activeFilter == NotificationFilter.all) return notifications;

    final types = switch (_activeFilter) {
      NotificationFilter.upvotes  => ['post_upvote', 'comment_upvote'],
      NotificationFilter.comments => ['reply', 'post_comment'],
      NotificationFilter.follows  => ['follow'],
      NotificationFilter.mentions => ['mention'],
      NotificationFilter.all      => <String>[],
    };

    return notifications.where((n) => types.contains(n.type)).toList();
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
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: tokens.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: tokens.textSecondary),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications marked as read',
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  backgroundColor: tokens.bgElevated,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: tokens.textSecondary),
            tooltip: 'More options',
            onPressed: () => _showMoreOptions(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _FilterChipRow(
            activeFilter: _activeFilter,
            onFilterChanged: (f) => setState(() => _activeFilter = f),
          ),
        ),
      ),
      body: notificationsState.when(
        data: (notifications) {
          final filtered = _applyFilter(notifications);

          if (filtered.isEmpty) {
            return _EmptyState(filter: _activeFilter);
          }

          final unread = filtered.where((n) => !n.isRead).toList();
          final read   = filtered.where((n) =>  n.isRead).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (unread.isNotEmpty) ...[
                _SectionHeader(label: 'New', count: unread.length),
                ...unread.asMap().entries.map((e) {
                  final n = e.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NotificationTile(
                        key: ValueKey(n.id),
                        notification: n,
                        onDismissed: () => _handleDismiss(context, n),
                        onTap: () => _handleTap(context, n),
                      ),
                      if (e.key < unread.length - 1)
                        Divider(height: 1, indent: 70, color: tokens.divider),
                    ],
                  );
                }),
              ],
              if (read.isNotEmpty) ...[
                _SectionHeader(label: 'Earlier'),
                ...read.asMap().entries.map((e) {
                  final n = e.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NotificationTile(
                        key: ValueKey(n.id),
                        notification: n,
                        onDismissed: () => _handleDismiss(context, n),
                        onTap: () => _handleTap(context, n),
                      ),
                      if (e.key < read.length - 1)
                        Divider(height: 1, indent: 70, color: tokens.divider),
                    ],
                  );
                }),
              ],
            ],
          );
        },
        loading: () => ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SkeletonLoader(height: 60),
          ),
        ),
        error: (error, stack) => ErrorWidgetCustom(
          message: 'Failed to load notifications: $error',
        ),
      ),
    );
  }

  // ── Handlers ─────────────────────────────────────────────
  // `ref` is always in scope — these are methods on ConsumerState

  void _handleDismiss(BuildContext context, NotificationModel notification) {
    ref
        .read(notificationsProvider.notifier)
        .removeNotification(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification removed'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref
              .read(notificationsProvider.notifier)
              .undoRemove(notification.id),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, NotificationModel notification) {
    ref.read(notificationsProvider.notifier).markAsRead(notification.id);

    if (notification.postId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PostDetailsScreen(postId: notification.postId!),
        ),
      );
    }
  }

  void _showMoreOptions(BuildContext context) {
    final tokens = context.tokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: tokens.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.done_all, color: tokens.brandOrange),
              title: Text(
                'Mark all as read',
                style: TextStyle(color: tokens.textPrimary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep_outlined, color: tokens.error),
              title: Text(
                'Clear all notifications',
                style: TextStyle(color: tokens.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmClearAll(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final tokens = context.tokens;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.bgElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear all notifications?',
          style: TextStyle(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: tokens.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(notificationsProvider.notifier)
                  .removeAllNotifications();
            },
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            child: const Text('Clear All'),
          ),
        ],
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
      height: 48,
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        border: Border(bottom: BorderSide(color: tokens.divider, width: 1)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: NotificationFilter.values.map((filter) {
          final isActive = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? tokens.brandOrange.withOpacity(0.15)
                      : tokens.bgElevated,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive
                        ? tokens.brandOrange
                        : tokens.borderDefault,
                    width: 1,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? tokens.brandOrange
                        : tokens.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Section Header  (NEW • 3) / (EARLIER)
// ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;

  const _SectionHeader({required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: tokens.textSecondary,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: tokens.brandOrange,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
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

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: tokens.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            filter == NotificationFilter.all
                ? 'No notifications yet'
                : 'No ${filter.label.toLowerCase()} notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later!',
            style: TextStyle(fontSize: 14, color: tokens.textSecondary),
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

  const _NotificationTile({
    super.key,
    required this.notification,
    required this.onDismissed,
    required this.onTap,
  });

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  String _getNotificationText() {
    switch (notification.type) {
      case 'post_upvote':    return 'upvoted your post';
      case 'comment_upvote': return 'upvoted your comment';
      case 'reply':          return 'replied to your comment';
      case 'post_comment':   return 'commented on your post';
      case 'follow':         return 'started following you';
      case 'mention':        return 'mentioned you';
      default:               return 'interacted with your content';
    }
  }

  /// Maps notification type → accent color using RedditTokens.
  Color _typeColor(BuildContext context) {
    final tokens = context.tokens;
    switch (notification.type) {
      case 'post_upvote':
      case 'comment_upvote': return tokens.upvote;               // #FF4500
      case 'reply':
      case 'post_comment':   return tokens.brandBlue;            // #24A0ED
      case 'follow':         return const Color(0xFF9B59B6);     // purple
      case 'mention':        return tokens.success;              // #46D160
      default:               return tokens.voteNeutral;
    }
  }

  IconData _typeIcon() {
    switch (notification.type) {
      case 'post_upvote':
      case 'comment_upvote': return Icons.arrow_upward;
      case 'reply':
      case 'post_comment':   return Icons.chat_bubble_rounded;
      case 'follow':         return Icons.person_add_rounded;
      case 'mention':        return Icons.alternate_email_rounded;
      default:               return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color  = _typeColor(context);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: tokens.error,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDismissed(),
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.04),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : color.withOpacity(0.04),
            border: Border(
              left: BorderSide(
                color: notification.isRead ? Colors.transparent : color,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar + type badge ──────────────────────
              _NotifAvatar(
                notification: notification,
                typeColor: color,
                typeIcon: _typeIcon(),
              ),
              const SizedBox(width: 12),

              // ── Text body ────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "u/username  action text" as RichText
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'u/${notification.actorUsername} ',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: notification.isRead
                                  ? tokens.textPrimary
                                  : color,
                              fontFamily: 'IBMPlexSans',
                            ),
                          ),
                          TextSpan(
                            text: _getNotificationText(),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: notification.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: notification.isRead
                                  ? tokens.textSecondary
                                  : tokens.textPrimary,
                              fontFamily: 'IBMPlexSans',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Unread dot ───────────────────────────────
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Avatar  (initials circle + colored type badge)
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
        CircleAvatar(
          radius: 21,
          backgroundColor: typeColor.withOpacity(0.12),
          backgroundImage: notification.actorAvatarUrl != null
              ? NetworkImage(notification.actorAvatarUrl!)
              : null,
          child: notification.actorAvatarUrl == null
              ? Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                )
              : null,
        ),
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: typeColor,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.bgPage, width: 2),
            ),
            child: Icon(typeIcon, size: 9, color: Colors.white),
          ),
        ),
      ],
    );
  }
}