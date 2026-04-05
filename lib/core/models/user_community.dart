// lib/core/models/user_community.dart

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'role': role,
        'joined_at': joinedAt.toIso8601String(),
        'posts_count': postsCount,
        'members_count': membersCount,
      };

  UserCommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? role,
    DateTime? joinedAt,
    int? postsCount,
    int? membersCount,
  }) {
    return UserCommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      postsCount: postsCount ?? this.postsCount,
      membersCount: membersCount ?? this.membersCount,
    );
  }

  bool get isAdmin => role == 'admin';
}
