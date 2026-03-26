// ========================================================
// post_models.dart - جميع نماذج المنشورات في ملف واحد
// ========================================================

// ----------------------------------------
// نموذج الصورة (مشترك)
// ----------------------------------------
class PostImage {
  final String id;
  final String imageUrl;

  PostImage({required this.id, required this.imageUrl});

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id']?.toString() ?? '',
      imageUrl: json['url']?.toString() ?? json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image_url': imageUrl};
  }
}

// ----------------------------------------
// نموذج التاج (Flair)
// ----------------------------------------
class FlairModel {
  final String id;
  final String name;
  final String? color;

  FlairModel({
    required this.id,
    required this.name,
    this.color,
  });

  factory FlairModel.fromJson(Map<String, dynamic> json) {
    return FlairModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}

// ----------------------------------------
// نموذج المجتمع (مشترك)
// ----------------------------------------
class CommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? bannerUrl;
  final int membersCount;
  final int postsCount;
  final DateTime createdAt;
  final bool isMember;

  CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.bannerUrl,
    required this.membersCount,
    required this.postsCount,
    required this.createdAt,
    required this.isMember,
  });

  factory CommunityModel.empty({String name = ''}) {
    return CommunityModel(
      id: '',
      name: name,
      membersCount: 0,
      postsCount: 0,
      createdAt: DateTime.now(),
      isMember: false,
    );
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      membersCount: (json['members_count'] as num?)?.toInt() ?? 0,
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isMember: json['is_member'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'banner_url': bannerUrl,
      'members_count': membersCount,
      'posts_count': postsCount,
      'created_at': createdAt.toIso8601String(),
      'is_member': isMember,
    };
  }
}

// ----------------------------------------
// نموذج مجتمع المستخدم
// ----------------------------------------
class UserCommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String role;
  final DateTime joinedAt;
  final int postsCount;
  final int membersCount;

  UserCommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.role,
    required this.joinedAt,
    required this.postsCount,
    required this.membersCount,
  });

  factory UserCommunityModel.fromJson(Map<String, dynamic> json) {
    return UserCommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      role: json['role']?.toString() ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      membersCount: (json['members_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'posts_count': postsCount,
      'members_count': membersCount,
    };
  }

  bool get isAdmin => role == 'admin';
}

// ----------------------------------------
// نموذج التعليق (مشترك)
// ----------------------------------------
class CommentModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int level; // مستوى التعليق في الشجرة

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
    List<CommentModel> repliesList = [];
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .map((replyJson) => CommentModel.fromJson(replyJson as Map<String, dynamic>))
          .toList();
    }

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
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      userVote: json['user_vote'] != null ? (json['user_vote'] as num).toInt() : null,
      postId: json['post_id']?.toString(),
      replies: repliesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

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

// ----------------------------------------
// نموذج المستخدم (UserProfile)
// ----------------------------------------
class UserProfileModel {
  final String id;
  final String username;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final int karma;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.username,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.karma = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      bio: json['bio']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      karma: (json['karma'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
      'karma': karma,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_following': isFollowing,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayName => fullName ?? username;
  String get initials => username.isNotEmpty ? username[0].toUpperCase() : '?';
}

// ----------------------------------------
// نموذج الإشعارات (Notification)
// ----------------------------------------
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

  Map<String, dynamic> toJson() {
    return {
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
  }
}

// ----------------------------------------
// النموذج الأساسي للمنشور في التغذية الرئيسية
// ----------------------------------------
class FeedPostModel {
  final String id;
  final String title;           // ✅ جديد
  final String content;
  final String? linkUrl;
  final String? postType;
  final DateTime createdAt;
  final String authorId;
  String? authorUsername;
  String? authorFullName;
  String? authorAvatarUrl;
  final int score;
  final double hotScore;
  final int? userVote;
  final int commentsCount;
  final List<PostImage>? images;
  
  // ✅ مجتمع المنشور (واحد فقط)
  final String communityId;
  final String communityName;
  final String? communityImageUrl;
  
  // ✅ تاج المنشور (اختياري)
  final String? flairId;
  final String? flairName;
  final String? flairColor;

  FeedPostModel({
    required this.id,
    required this.title,
    required this.content,
    this.linkUrl,
    this.postType,
    required this.createdAt,
    required this.authorId,
    required this.score,
    required this.hotScore,
    required this.commentsCount,
    this.userVote,
    this.images,
    this.authorUsername,
    this.authorFullName,
    this.authorAvatarUrl,
    required this.communityId,
    required this.communityName,
    this.communityImageUrl,
    this.flairId,
    this.flairName,
    this.flairColor,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    List<PostImage>? imagesList;
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((imgJson) => PostImage.fromJson(imgJson as Map<String, dynamic>))
          .toList();
    }

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
      hotScore: json['hot_score'] != null ? (json['hot_score'] as num).toDouble() : 0.0,
      commentsCount: json['comments_count'] != null ? (json['comments_count'] as num).toInt() : 0,
      userVote: json['user_vote'] != null ? (json['user_vote'] as num).toInt() : null,
      images: imagesList,
      communityId: json['community_id']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? '',
      communityImageUrl: json['community_image_url']?.toString(),
      flairId: json['flair_id']?.toString(),
      flairName: json['flair_name']?.toString(),
      flairColor: json['flair_color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'community_id': communityId,
      'community_name': communityName,
      'community_image_url': communityImageUrl,
      'flair_id': flairId,
      'flair_name': flairName,
      'flair_color': flairColor,
    };
  }

  FeedPostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? linkUrl,
    String? postType,
    DateTime? createdAt,
    String? authorId,
    int? score,
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

  PostDetailsModel toDetailsModel({List<CommentModel> comments = const []}) {
    return PostDetailsModel(
      id: id,
      title: title,
      content: content,
      linkUrl: linkUrl,
      postType: postType,
      createdAt: createdAt,
      authorId: authorId,
      authorUsername: authorUsername ?? '',
      authorFullName: authorFullName,
      authorAvatarUrl: authorAvatarUrl,
      score: score,
      userVote: userVote,
      commentsCount: commentsCount,
      images: images ?? [],
      communityId: communityId,
      communityName: communityName,
      communityImageUrl: communityImageUrl,
      flairId: flairId,
      flairName: flairName,
      flairColor: flairColor,
      comments: comments,
    );
  }
}

// ----------------------------------------
// نموذج تفاصيل المنشور (صفحة المنشور مع التعليقات)
// ----------------------------------------
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
  
  // ✅ مجتمع المنشور
  final String communityId;
  final String communityName;
  final String? communityImageUrl;
  
  // ✅ تاج المنشور
  final String? flairId;
  final String? flairName;
  final String? flairColor;
  
  final List<CommentModel> comments;

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
  });

  factory PostDetailsModel.fromJson(Map<String, dynamic> json) {
    List<PostImage> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((imgJson) => PostImage.fromJson(imgJson as Map<String, dynamic>))
          .toList();
    }

    List<CommentModel> commentsList = [];
    if (json['comments'] != null && json['comments'] is List) {
      commentsList = (json['comments'] as List)
          .map((cJson) => CommentModel.fromJson(cJson as Map<String, dynamic>))
          .toList();
    }

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
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      userVote: json['user_vote'] != null ? (json['user_vote'] as num).toInt() : null,
      commentsCount: json['comments_count'] != null ? (json['comments_count'] as num).toInt() : 0,
      images: imagesList,
      communityId: json['community_id']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? '',
      communityImageUrl: json['community_image_url']?.toString(),
      flairId: json['flair_id']?.toString(),
      flairName: json['flair_name']?.toString(),
      flairColor: json['flair_color']?.toString(),
      comments: commentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }

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
    );
  }

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
    );
  }
}