import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/services/cash.dart' as cache_service;
import 'package:mini_reddit_v2/core/utils/supabase_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// RPC / cache often returns [Map<dynamic, dynamic>]; [as Map<String, dynamic>] throws.
Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected JSON object, got ${value.runtimeType}');
}

class ProfileDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;
  final cache_service.CashService cash = cache_service.CashService();

  // Get profile
  Future<UserProfileModel> getProfile(String userId) async {
    print('Fetching profile for user: $userId');
    final response = await _supabase.rpc(
      'get_user_profile',
      params: {
        'p_user_id': userId,
        'p_current_user_id': Supabase.instance.client.auth.currentUser?.id,
      },
    );

    if (response is List && response.isNotEmpty) {
      return UserProfileModel.fromJson(_jsonMap(response.first));
    } else if (response is Map) {
      return UserProfileModel.fromJson(_jsonMap(response));
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
    var loadedFromCache = false;

    if (!forceRefresh && cash.exist(cache_service.Key.userPost)) {
      final cached = cash.get(cache_service.Key.userPost);
      if (cached is Map) {
        final cachedUserId = cached['userId']?.toString();
        if (cachedUserId == userId) {
          response = cached['data'];
          loadedFromCache = true;
        }
      }
    }

    if (!loadedFromCache) {
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

    if (!loadedFromCache) {
      cash.save(cache_service.Key.userPost, {'userId': userId, 'data': data});
    }

    return data.map((json) => FeedPostModel.fromJson(_jsonMap(json))).toList();
  }

  Future<List<UserProfileCommentItem>> getUserComments({
    bool forceRefresh = false,
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    dynamic response;
    var loadedFromCache = false;

    if (!forceRefresh && cash.exist(cache_service.Key.userComment)) {
      final cached = cash.get(cache_service.Key.userComment);
      if (cached is Map) {
        final cachedUserId = cached['userId']?.toString();
        if (cachedUserId == userId) {
          response = cached['data'];
          loadedFromCache = true;
        }
      }
    }

    if (!loadedFromCache) {
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

    final List<dynamic> data = response is List ? response : [response];

    if (!loadedFromCache) {
      cash.save(cache_service.Key.userComment, {
        'userId': userId,
        'data': data,
      });
    }

    return data
        .map((json) => UserProfileCommentItem.fromJson(_jsonMap(json)))
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

    if (cash.exist(cache_service.Key.userSavedPost) && !forceRefresh) {
      response = cash.get(cache_service.Key.userSavedPost);
      needToCash = false;
    } else {
      response = await Supabase.instance.client.rpc(
        'get_saved_posts',
        params: {'p_user_id': userId, 'p_limit': limit, 'p_offset': offset},
      );
    }

    if (response == null) return [];

    final List<dynamic> data = response is List ? response : [response];

    if (needToCash) cash.save(cache_service.Key.userSavedPost, data);

    return data.map((json) => FeedPostModel.fromJson(_jsonMap(json))).toList();
  }

  Future<UserProfileModel> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            if (username != null) 'username': username,
            if (fullName != null) 'full_name': fullName,
            if (bio != null) 'bio': bio,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
            if (bannerUrl != null) 'banner_url': bannerUrl,
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
    final String bucketName = SupabaseText.userProfileBuckets;
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(fileName, imageFile);

      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading post image: $e');
      return null;
    }
  }

  Future<String?> uploadBannerImage(File imageFile) async {
    final String bucketName = SupabaseText.bannerBuckets;
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(fileName, imageFile);

      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading banner image: $e');
      return null;
    }
  }
}
