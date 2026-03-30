// lib/core/models/notification.dart

class NotificationModel {
  final String id;
  final String actorId;
  final String actorUsername;
  final String? actorAvatarUrl;
  final String type;
  final String? postId;
  final String? commentId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.actorId,
    required this.actorUsername,
    this.actorAvatarUrl,
    required this.type,
    this.postId,
    this.commentId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      actorId: json['actor_id']?.toString() ?? '',
      actorUsername: json['actor_username']?.toString() ?? '',
      actorAvatarUrl: json['actor_avatar_url']?.toString(),
      type: json['type']?.toString() ?? '',
      postId: json['post_id']?.toString(),
      commentId: json['comment_id']?.toString(),
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'actor_id': actorId,
        'actor_username': actorUsername,
        'actor_avatar_url': actorAvatarUrl,
        'type': type,
        'post_id': postId,
        'comment_id': commentId,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({
    String? id,
    String? actorId,
    String? actorUsername,
    String? actorAvatarUrl,
    String? type,
    String? postId,
    String? commentId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      actorUsername: actorUsername ?? this.actorUsername,
      actorAvatarUrl: actorAvatarUrl ?? this.actorAvatarUrl,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
