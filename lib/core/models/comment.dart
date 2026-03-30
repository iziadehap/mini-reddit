// lib/core/models/comment.dart

class CommentModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int level;
  final String authorId;
  final String authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;
  final int score;
  final int? userVote;
  final String? postId;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.level = 0,
    required this.authorId,
    required this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
    required this.score,
    this.userVote,
    this.postId,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      parentId: json['parent_id']?.toString(),
      level: (json['level'] as num?)?.toInt() ?? 0,
      authorId: json['author_id']?.toString() ?? '',
      authorUsername: json['author_username']?.toString() ?? '',
      authorFullName: json['author_full_name']?.toString(),
      authorAvatarUrl: json['author_avatar_url']?.toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      userVote: (json['user_vote'] as num?)?.toInt(),
      postId: json['post_id']?.toString(),
      replies: (json['replies'] as List?)
              ?.map((replyJson) => CommentModel.fromJson(replyJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'parent_id': parentId,
        'level': level,
        'author_id': authorId,
        'author_username': authorUsername,
        'author_full_name': authorFullName,
        'author_avatar_url': authorAvatarUrl,
        'score': score,
        'user_vote': userVote,
        'post_id': postId,
      };

  CommentModel copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? parentId,
    int? level,
    String? authorId,
    String? authorUsername,
    String? authorFullName,
    String? authorAvatarUrl,
    int? score,
    int? userVote,
    bool clearUserVote = false,
    String? postId,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorFullName: authorFullName ?? this.authorFullName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      score: score ?? this.score,
      userVote: clearUserVote ? null : (userVote ?? this.userVote),
      postId: postId ?? this.postId,
      replies: replies ?? this.replies,
    );
  }
}
