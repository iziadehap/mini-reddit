// ============================================
// COMMUNITY DETAILS MODELS (CLEAN VERSION)
// ============================================

import 'package:mini_reddit_v2/core/models/models.dart';

class CommunityDetailsModel {
  final bool success;
  final String? message;
  final CommunityModel? community;
  final List<Admin> admins;
  final CommunityStats stats;
  final UserStatus userStatus;

  CommunityDetailsModel({
    required this.success,
    this.message,
    this.community,
    this.admins = const [],
    required this.stats,
    required this.userStatus,
  });

  factory CommunityDetailsModel.fromJson(Map<String, dynamic> json) {
    return CommunityDetailsModel(
      success: json['success'] ?? false,
      message: json['message'],
      community: json['community'] != null
          ? CommunityModel.fromJson(json['community'])
          : null,
      admins:
          (json['admins'] as List<dynamic>?)
              ?.map((e) => Admin.fromJson(e))
              .toList() ??
          [],
      stats: CommunityStats.fromJson(json['stats'] ?? {}),
      userStatus: UserStatus.fromJson(json['user_status'] ?? {}),
    );
  }
}

// // ============================================
// // COMMUNITY INFO
// // ============================================

// class Community {
//   final String id;
//   final String name;
//   final String? description;
//   final String? imageUrl;
//   final String? bannerUrl;
//   final DateTime createdAt;
//   final String? createdBy;
//
//   Community({
//     required this.id,
//     required this.name,
//     this.description,
//     this.imageUrl,
//     this.bannerUrl,
//     required this.createdAt,
//     this.createdBy,
//   });
//
//   factory Community.fromJson(Map<String, dynamic> json) {
//     return Community(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       imageUrl: json['image_url'],
//       bannerUrl: json['banner_url'],
//       createdAt: DateTime.parse(json['created_at']),
//       createdBy: json['created_by'],
//     );
//   }
// }

// ============================================
// ADMIN INFO (بدون is_online)
// ============================================

class Admin {
  final String id;
  final String username;
  final String? avatarUrl;
  final String role;

  Admin({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.role,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      role: json['role'],
    );
  }
}

// ============================================
// STATS (بدون online_count)
// ============================================

class CommunityStats {
  final int membersCount;
  final int postsCount;

  CommunityStats({this.membersCount = 0, this.postsCount = 0});

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      membersCount: json['members_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
    );
  }
}

// ============================================
// USER STATUS
// ============================================

class UserStatus {
  final bool isMember;
  final bool isAdmin;
  final DateTime? joinedAt;

  UserStatus({this.isMember = false, this.isAdmin = false, this.joinedAt});

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      isMember: json['is_member'] ?? false,
      isAdmin: json['is_admin'] ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : null,
    );
  }
}
