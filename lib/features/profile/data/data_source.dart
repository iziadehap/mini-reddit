import 'dart:io';

import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/services/cash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDataSource {
  final cash = CashService();

  // Get profile
  Future<UserProfileModel> getProfile(String userId) async {
    print('Fetching profile for user: $userId');
    final response = await Supabase.instance.client.rpc(
      'get_user_profile',
      params: {
        'p_user_id': userId,
        'p_current_user_id': Supabase.instance.client.auth.currentUser?.id,
      },
    );

    if (response is List && response.isNotEmpty) {
      return UserProfileModel.fromJson(response.first as Map<String, dynamic>);
    } else if (response is Map) {
      return UserProfileModel.fromJson(response as Map<String, dynamic>);
    }
    throw Exception('Profile not found');
  }

  // ============================================
  // GET USER POSTS (NEW!)
  // ============================================

  Future<List<FeedPostModel>> getUserPosts({
    bool forceRefresh = false,
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    dynamic response;
    bool needToCash = true;
    if (cash.exist(Key.userPost) && !forceRefresh) {
      response = cash.get(Key.userPost);
      needToCash = false;
    } else {
      response = await Supabase.instance.client.rpc(
        'get_user_posts',
        params: {
          'p_target_user_id': userId,
          'p_limit': limit,
          'p_offset': offset,
          'p_current_user_id': Supabase.instance.client.auth.currentUser?.id,
        },
      );
    }

    if (response == null) return [];

    final List<dynamic> data = response is List ? response : [response];

    if (needToCash) cash.save(Key.userPost, data);

    return data
        .map((json) => FeedPostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserProfileCommentItem>> getUserComments({
    bool forceRefresh = false,
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    dynamic response;
    bool needToCash = true;
    if (cash.exist(Key.userComment) && !forceRefresh) {
      response = cash.get(Key.userComment);
      needToCash = false;
    } else {
      response = await Supabase.instance.client.rpc(
        'get_user_comments',
        params: {
          'p_target_user_id': userId,
          'p_limit': limit,
          'p_offset': offset,
          'p_current_user_id': Supabase.instance.client.auth.currentUser?.id,
        },
      );
    }

    if (response == null) return [];

    if (needToCash) cash.save(Key.userComment, response);

    final List<dynamic> data = response is List ? response : [response];

    return data
        .map(
          (json) =>
              UserProfileCommentItem.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<FeedPostModel>> getUserSavedPosts({
    bool forceRefresh = false,
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    dynamic response;
    bool needToCash = true;

    if (cash.exist(Key.userSavedPost) && !forceRefresh) {
      response = cash.get(Key.userSavedPost);
      needToCash = false;
    } else {
      response = await Supabase.instance.client.rpc(
        'get_saved_posts',
        params: {'p_user_id': userId, 'p_limit': limit, 'p_offset': offset},
      );
    }

    if (response == null) return [];

    final List<dynamic> data = response is List ? response : [response];

    if (needToCash) cash.save(Key.userSavedPost, data);

    return data
        .map((json) => FeedPostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<UserProfileModel> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            if (username != null) 'username': username,
            if (fullName != null) 'full_name': fullName,
            if (bio != null) 'bio': bio,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String?> uploadPostImage(File imageFile) async {
    final String bucketName = 'users_profile_images';
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(fileName, imageFile);

      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
