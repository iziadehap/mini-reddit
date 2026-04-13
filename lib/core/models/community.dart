// lib/core/models/community.dart

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
  final String? createdBy;

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
    this.createdBy,
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
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'banner_url': bannerUrl,
    'members_count': membersCount,
    'posts_count': postsCount,
    'created_at': createdAt.toIso8601String(),
    'is_member': isMember,
    'created_by': createdBy,
  };

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
    int? membersCount,
    int? postsCount,
    DateTime? createdAt,
    bool? isMember,
    String? createdBy,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      membersCount: membersCount ?? this.membersCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      isMember: isMember ?? this.isMember,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
