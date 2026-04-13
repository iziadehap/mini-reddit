// lib/core/models/feed_post.dart

import 'post_image.dart';

class FeedPostModel {
  final String id;
  final String title;
  final String content;
  final String? linkUrl;
  final String? postType;
  final DateTime createdAt;
  final String authorId;
  final String? authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;
  final int score;
  final bool isSaved;
  final double hotScore;
  final int? userVote;
  final int commentsCount;
  final List<PostImage>? images;
  final String communityId;
  final String communityName;
  final String? communityImageUrl;
  final String? flairId;
  final String? flairName;
  final String? flairColor;
  final bool? isDeleted;

  FeedPostModel({
    required this.id,
    required this.title,
    required this.content,
    this.linkUrl,
    this.postType,
    required this.createdAt,
    required this.authorId,
    this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
    required this.score,
    required this.isSaved,
    required this.hotScore,
    required this.commentsCount,
    this.userVote,
    this.images,
    required this.communityId,
    required this.communityName,
    this.communityImageUrl,
    this.flairId,
    this.flairName,
    this.flairColor,
    this.isDeleted,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    return FeedPostModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      linkUrl: json['link_url']?.toString(),
      postType: json['post_type']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      authorId: json['author_id']?.toString() ?? '',
      authorUsername: json['author_username']?.toString(),
      authorFullName: json['author_full_name']?.toString(),
      authorAvatarUrl: json['author_avatar_url']?.toString(),
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      hotScore: json['hot_score'] != null
          ? (json['hot_score'] as num).toDouble()
          : 0.0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      userVote: (json['user_vote'] as num?)?.toInt(),
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map((m) => PostImage.fromJson(Map<String, dynamic>.from(m)))
                .toList()
          : null,
      isSaved: json['is_saved'] ?? false,
      communityId: json['community_id']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? '',
      communityImageUrl: json['community_image_url']?.toString(),
      flairId: json['flair_id']?.toString(),
      flairName: json['flair_name']?.toString(),
      flairColor: json['flair_color']?.toString(),
      isDeleted: json['is_deleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'link_url': linkUrl,
    'post_type': postType,
    'created_at': createdAt.toIso8601String(),
    'author_id': authorId,
    'author_username': authorUsername,
    'author_full_name': authorFullName,
    'author_avatar_url': authorAvatarUrl,
    'score': score,
    'hot_score': hotScore,
    'comments_count': commentsCount,
    'user_vote': userVote,
    'images': images?.map((img) => img.toJson()).toList(),
    'is_saved': isSaved,
    'community_id': communityId,
    'community_name': communityName,
    'community_image_url': communityImageUrl,
    'flair_id': flairId,
    'flair_name': flairName,
    'flair_color': flairColor,
    'is_deleted': isDeleted,
  };

  // ✅ FIXED: Added isSaved parameter
  FeedPostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? linkUrl,
    String? postType,
    DateTime? createdAt,
    String? authorId,
    int? score,
    bool? isSaved, // ✅ ADD THIS
    double? hotScore,
    int? commentsCount,
    int? userVote,
    bool clearUserVote = false,
    List<PostImage>? images,
    String? authorUsername,
    String? authorFullName,
    String? authorAvatarUrl,
    String? communityId,
    String? communityName,
    String? communityImageUrl,
    String? flairId,
    String? flairName,
    String? flairColor,
    bool? isDeleted,
  }) {
    return FeedPostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      linkUrl: linkUrl ?? this.linkUrl,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      score: score ?? this.score,
      isSaved: isSaved ?? this.isSaved, // ✅ FIXED
      hotScore: hotScore ?? this.hotScore,
      commentsCount: commentsCount ?? this.commentsCount,
      userVote: clearUserVote ? null : (userVote ?? this.userVote),
      images: images ?? this.images,
      authorUsername: authorUsername ?? this.authorUsername,
      authorFullName: authorFullName ?? this.authorFullName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      communityImageUrl: communityImageUrl ?? this.communityImageUrl,
      flairId: flairId ?? this.flairId,
      flairName: flairName ?? this.flairName,
      flairColor: flairColor ?? this.flairColor,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  FeedPostModel toggleVote(int voteValue) {
    if (userVote == voteValue) {
      return copyWith(
        clearUserVote: true,
        score: score + (voteValue == 1 ? -1 : 1),
      );
    } else if (userVote != null) {
      return copyWith(
        userVote: voteValue,
        score: score - (userVote ?? 0) + voteValue,
      );
    } else {
      return copyWith(userVote: voteValue, score: score + voteValue);
    }
  }

  // ✅ ADD THIS: Toggle save method
  FeedPostModel toggleSave() {
    return copyWith(isSaved: !isSaved);
  }
}
