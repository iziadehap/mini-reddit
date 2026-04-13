// lib/core/models/user_profile_comment.dart

class UserProfileCommentItem {
  final String id;
  final String content;
  final DateTime createdAt;
  final int score;
  final String postId;
  final String postTitle;
  final String communityName;
  final int? userVote;

  UserProfileCommentItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.score,
    required this.postId,
    required this.postTitle,
    required this.communityName,
    this.userVote,
  });

  factory UserProfileCommentItem.fromJson(Map<String, dynamic> json) {
    return UserProfileCommentItem(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      postId: json['post_id']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? '',
      userVote: (json['user_vote'] as num?)?.toInt(),
    );
  }
}
