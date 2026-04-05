import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/utils/supabase_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  // todo : handel this , this can better than this (create_post)

  Future<SuccessModel> savePost(String postId) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase.rpc(
      'save_post',
      params: {'p_post_id': postId, 'p_user_id': currentUserId},
    );

    return SuccessModel.fromJson(response);
  }

  // ============================================
  // UNSAVE POST
  // ============================================

  Future<SuccessModel> unsavePost(String postId) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase.rpc(
      'unsave_post',
      params: {'p_post_id': postId, 'p_user_id': currentUserId},
    );

    return SuccessModel.fromJson(response);
  }

  Future<FeedPostModel> createPost({
    required String communityId,
    required String title,
    required String content,
    String postType = 'text',
    String? linkUrl,
    String? flairId,
    List<String>? imageUrls,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.rpc(
        'create_post',
        params: {
          'p_user_id': userId,
          'p_community_id': communityId,
          'p_title': title,
          'p_content': content,
          'p_post_type': postType,
          if (linkUrl != null) 'p_link_url': linkUrl,
          if (flairId != null) 'p_flair_id': flairId,
          if (imageUrls != null && imageUrls.isNotEmpty)
            'p_image_urls': imageUrls,
        },
      );

      final Map<String, dynamic> responseMap = Map<String, dynamic>.from(
        response,
      );

      if (responseMap['success'] == true) {
        // Fetch the newly created post details to return a FeedPostModel
        // Since create_post only returns {success, message, post_id}
        final postId = responseMap['post_id'] as String;
        final postDetails = await _supabase.rpc(
          'get_post_details',
          params: {'p_post_id': postId, 'p_current_user_id': userId},
        );

        if (postDetails is List && postDetails.isNotEmpty) {
          return FeedPostModel.fromJson(
            postDetails.first as Map<String, dynamic>,
          );
        }
        throw Exception('Failed to fetch created post details');
      } else {
        throw Exception(responseMap['message']);
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<PostDetailsModel> getPostDetails({
    required String postId,
    required String userId,
  }) async {
    final response = await _supabase.rpc(
      'get_post_details',
      params: {'p_post_id': postId, 'p_current_user_id': userId},
    );

    // debugPrint('post details data from data source: $response');

    // Check if response is a list and has items
    if (response is List && response.isNotEmpty) {
      return PostDetailsModel.fromJson(response.first as Map<String, dynamic>);
    } else {
      throw Exception('Post not found or empty response');
    }
  }

  Future<dynamic> voteComment({
    required String userId,
    required String commentId,
    required int value, // 1 أو -1
  }) async {
    final response = await _supabase.rpc(
      'vote_comment',
      params: {
        'p_comment_id': commentId,
        'p_value': value,
        'p_user_id': userId,
      },
    );

    // debugPrint('Vote comment response: $response');
    return response;
  }

  Future<Map<String, dynamic>> votePost({
    required String postId,
    required int value,
    required String userId,
  }) async {
    final response = await _supabase.rpc(
      'vote_post',
      params: {'p_post_id': postId, 'p_value': value, 'p_user_id': userId},
    );

    return response;
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String userId,
    String? parentId, // ← أضفنا parentId اختياري
  }) async {
    final res = await _supabase.rpc(
      'add_comment',
      params: {
        'p_post_id': postId,
        'p_user_id': userId,
        'p_content': content,
        if (parentId != null) 'p_parent_id': parentId,
      },
    );
    debugPrint('Add comment response: $res');
  }

  Future<List<String>> uploadPostImage(List<File> imageFiles) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final List<Future<String>> uploadTasks = imageFiles.map((file) async {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final path = '$userId/$fileName';

        await Supabase.instance.client.storage
            .from(SupabaseText.postImageBuckets)
            .upload(path, file);

        return Supabase.instance.client.storage
            .from(SupabaseText.postImageBuckets)
            .getPublicUrl(path);
      }).toList();

      final List<String> imageUrls = await Future.wait(uploadTasks);
      return imageUrls;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return [];
    }
  }

  // حذف تعليق
  Future<dynamic> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('comments')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .eq('user_id', userId)
          .select();
      debugPrint('Delete response: $response');
      return response;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      rethrow;
    }
  }
}
