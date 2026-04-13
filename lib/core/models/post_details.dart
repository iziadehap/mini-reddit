// lib/core/models/post_details.dart

import 'post_image.dart';
import 'comment.dart';
import 'feed_post.dart';

class PostDetailsModel {
  final String id;
  final String title;
  final String content;
  final String? linkUrl;
  final String? postType;
  final DateTime createdAt;
  final String authorId;
  final String authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;
  final int score;
  final int? userVote;
  final int commentsCount;
  final List<PostImage> images;
  final String communityId;
  final String communityName;
  final String? communityImageUrl;
  final String? flairId;
  final String? flairName;
  final String? flairColor;
  final List<CommentModel> comments;
  final bool isSaved; // ✅ ADD THIS FIELD

  PostDetailsModel({
    required this.id,
    required this.title,
    required this.content,
    this.linkUrl,
    this.postType,
    required this.createdAt,
    required this.authorId,
    required this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
    required this.score,
    this.userVote,
    required this.commentsCount,
    required this.images,
    required this.communityId,
    required this.communityName,
    this.communityImageUrl,
    this.flairId,
    this.flairName,
    this.flairColor,
    required this.comments,
    this.isSaved = false, // ✅ ADD THIS
  });

  factory PostDetailsModel.fromJson(Map<String, dynamic> json) {
    return PostDetailsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      linkUrl: json['link_url']?.toString(),
      postType: json['post_type']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      authorId: json['author_id']?.toString() ?? '',
      authorUsername: json['author_username']?.toString() ?? '',
      authorFullName: json['author_full_name']?.toString(),
      authorAvatarUrl: json['author_avatar_url']?.toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      userVote: (json['user_vote'] as num?)?.toInt(),
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      images:
          (json['images'] as List?)
              ?.map(
                (imgJson) =>
                    PostImage.fromJson(imgJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      communityId: json['community_id']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? '',
      communityImageUrl: json['community_image_url']?.toString(),
      flairId: json['flair_id']?.toString(),
      flairName: json['flair_name']?.toString(),
      flairColor: json['flair_color']?.toString(),
      comments:
          (json['comments'] as List?)
              ?.map(
                (cJson) => CommentModel.fromJson(cJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isSaved: json['is_saved'] ?? false, // ✅ ADD THIS
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
    'user_vote': userVote,
    'comments_count': commentsCount,
    'images': images.map((img) => img.toJson()).toList(),
    'community_id': communityId,
    'community_name': communityName,
    'community_image_url': communityImageUrl,
    'flair_id': flairId,
    'flair_name': flairName,
    'flair_color': flairColor,
    'comments': comments.map((c) => c.toJson()).toList(),
    'is_saved': isSaved, // ✅ ADD THIS
  };

  PostDetailsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? linkUrl,
    String? postType,
    DateTime? createdAt,
    String? authorId,
    String? authorUsername,
    String? authorFullName,
    String? authorAvatarUrl,
    int? score,
    int? userVote,
    bool clearUserVote = false,
    int? commentsCount,
    List<PostImage>? images,
    String? communityId,
    String? communityName,
    String? communityImageUrl,
    String? flairId,
    String? flairName,
    String? flairColor,
    List<CommentModel>? comments,
    bool? isSaved, // ✅ ADD THIS
  }) {
    return PostDetailsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      linkUrl: linkUrl ?? this.linkUrl,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorFullName: authorFullName ?? this.authorFullName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      score: score ?? this.score,
      userVote: clearUserVote ? null : (userVote ?? this.userVote),
      commentsCount: commentsCount ?? this.commentsCount,
      images: images ?? this.images,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      communityImageUrl: communityImageUrl ?? this.communityImageUrl,
      flairId: flairId ?? this.flairId,
      flairName: flairName ?? this.flairName,
      flairColor: flairColor ?? this.flairColor,
      comments: comments ?? this.comments,
      isSaved: isSaved ?? this.isSaved, // ✅ ADD THIS
    );
  }

  // ✅ FIXED: Added isSaved
  FeedPostModel toFeedModel() {
    return FeedPostModel(
      id: id,
      title: title,
      content: content,
      linkUrl: linkUrl,
      postType: postType,
      createdAt: createdAt,
      authorId: authorId,
      authorUsername: authorUsername,
      authorFullName: authorFullName,
      authorAvatarUrl: authorAvatarUrl,
      score: score,
      hotScore: 0,
      commentsCount: commentsCount,
      userVote: userVote,
      images: images.isEmpty ? null : images,
      communityId: communityId,
      communityName: communityName,
      communityImageUrl: communityImageUrl,
      flairId: flairId,
      flairName: flairName,
      flairColor: flairColor,
      isSaved: isSaved, // ✅ ADD THIS
    );
  }
}
