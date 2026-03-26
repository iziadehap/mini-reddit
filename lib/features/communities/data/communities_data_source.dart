import 'dart:io';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  // الحصول على قائمة المجتمعات
  Future<List<CommunityModel>> getCommunities({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    try {
      final params = {
        'p_limit': limit,
        'p_offset': offset,
        if (search != null) 'p_search': search,
      };

      final data = await _supabase.rpc('get_communities', params: params);
      return (data as List)
          .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting communities: $e');
      return [];
    }
  }

  // الحصول على مجتمعات المستخدم
  Future<List<UserCommunityModel>> getUserCommunities({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = {
        'p_user_id': userId,
        'p_limit': limit,
        'p_offset': offset,
      };

      final data = await _supabase.rpc('get_user_communities', params: params);
      // print('User communities data: $data');
      return (data as List)
          .map((e) => UserCommunityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user communities: $e');
      return [];
    }
  }

  // إنشاء مجتمع جديد
  Future<Map<String, dynamic>> createCommunity({
    required String name,
    String? description,
    String? imageUrl,
    String? bannerUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.rpc(
        'create_community',
        params: {
          'p_name': name,
          'p_user_id': userId,
          if (description != null) 'p_description': description,
          if (imageUrl != null) 'p_image_url': imageUrl,
          if (bannerUrl != null) 'p_banner_url': bannerUrl,
        },
      );
      // todo : dont return map return community model
      print('Community created successfully: $response');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error creating community: $e');
      return {'success': false, 'message': 'Failed to create community: $e'};
    }
  }

  // الانضمام لمجتمع
  Future<Map<String, dynamic>> joinCommunity(String communityId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.rpc(
        'join_community',
        params: {'p_community_id': communityId, 'p_user_id': userId},
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error joining community: $e');
      return {'success': false, 'message': 'Failed to join community: $e'};
    }
  }

  // مغادرة المجتمع
  Future<Map<String, dynamic>> leaveCommunity(String communityId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.rpc(
        'leave_community',
        params: {'p_community_id': communityId, 'p_user_id': userId},
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error leaving community: $e');
      return {'success': false, 'message': 'Failed to leave community: $e'};
    }
  }

  Future<String> uploadCommunityImage(File file) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = '$userId/$fileName';

      await _supabase.storage.from('community_images').upload(path, file);

      return _supabase.storage.from('community_images').getPublicUrl(path);
    } catch (e) {
      print('Error uploading community icon: $e');
      rethrow;
    }
  }

  // البحث عن المجتمعات
  Future<List<CommunityModel>> searchCommunities(String query) async {
    final data = await getCommunities(search: query, limit: 20);
    print('Searching for communities: $query');
    print('Communities data: $data');
    return data;
  }

  // التحقق من عضوية المستخدم في مجتمع
  Future<bool> checkMembership(String communityId, String userId) async {
    try {
      final communities = await getUserCommunities(userId: userId);
      return communities.any((c) => c.id == communityId);
    } catch (e) {
      print('Error checking membership: $e');
      return false;
    }
  }

  // // إنشاء منشور جديد في مجتمع
  // Future<FeedPostModel> createPostInCommunity({
  //   required String communityId,
  //   required String title,
  //   required String content,
  //   String postType = 'text',
  //   String? linkUrl,
  //   String? flairId,
  //   List<String>? imageUrls,
  // }) async {
  //   try {
  //     final userId = _supabase.auth.currentUser?.id;
  //     if (userId == null) throw Exception('User not authenticated');

  //     final response = await _supabase.rpc(
  //       'create_post',
  //       params: {
  //         'p_user_id': userId,
  //         'p_community_id': communityId,
  //         'p_title': title,
  //         'p_content': content,
  //         'p_post_type': postType,
  //         if (linkUrl != null) 'p_link_url': linkUrl,
  //         if (flairId != null) 'p_flair_id': flairId,
  //         if (imageUrls != null && imageUrls.isNotEmpty)
  //           'p_image_urls': imageUrls,
  //       },
  //     );

  //     final Map<String, dynamic> responseMap = Map<String, dynamic>.from(
  //       response,
  //     );

  //     if (responseMap['success'] == true) {
  //       // Fetch the newly created post details to return a FeedPostModel
  //       // Since create_post only returns {success, message, post_id}
  //       final postId = responseMap['post_id'] as String;
  //       final postDetails = await _supabase.rpc(
  //         'get_post_details',
  //         params: {'p_post_id': postId, 'p_current_user_id': userId},
  //       );

  //       if (postDetails is List && postDetails.isNotEmpty) {
  //         return FeedPostModel.fromJson(
  //           postDetails.first as Map<String, dynamic>,
  //         );
  //       }
  //       throw Exception('Failed to fetch created post details');
  //     } else {
  //       throw Exception(responseMap['message']);
  //     }
  //   } catch (e) {
  //     print('Error creating post: $e');
  //     throw Exception('Failed to create post: $e');
  //   }
  // }

  // إضافة منشور موجود إلى مجتمع (مشاركة)
  Future<FeedPostModel> addPostToCommunity({
    required String originalPostId,
    required String targetCommunityId,
    String? additionalContent,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final originalPost = await _supabase
          .from('posts')
          .select('content, image_url, author_id')
          .eq('id', originalPostId)
          .single();

      final postData = {
        'community_id': targetCommunityId,
        'author_id': userId,
        'content': additionalContent ?? originalPost['content'],
        'image_url': originalPost['image_url'],
        'original_post_id': originalPostId,
        'original_author_id': originalPost['author_id'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
        'is_share': true,
      };

      final response = await _supabase.from('posts').insert(postData).select('''
            id,
            content,
            image_url,
            created_at,
            updated_at,
            author_id,
            community_id,
            profiles:author_id (
              username,
              full_name,
              avatar_url
            )
          ''').single();

      return FeedPostModel.fromJson({
        ...response,
        'author_username': response['profiles']?['username'],
        'author_full_name': response['profiles']?['full_name'],
        'author_avatar_url': response['profiles']?['avatar_url'],
        'score': 0,
        'hot_score': 0.0,
        'comments_count': 0,
        'communities_count': 1,
      });
    } catch (e) {
      throw Exception('Failed to add post to community: $e');
    }
  }

  // حذف منشور من مجتمع (حذف ناعم)
  Future<void> removePostFromCommunity(String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final post = await _supabase
          .from('posts')
          .select('author_id')
          .eq('id', postId)
          .single();

      if (post['author_id'] != userId) {
        throw Exception('You can only remove your own posts');
      }

      await _supabase
          .from('posts')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to remove post: $e');
    }
  }

  // الحصول على منشورات مجتمع معين
  Future<List<FeedPostModel>> getCommunityPosts({
    required String communityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final userId = _supabase.auth.currentUser?.id;

      // Get community name first for the hot feed filter
      final communityRes = await _supabase
          .from('communities')
          .select('name')
          .eq('id', communityId)
          .single();

      final String communityName = communityRes['name'];

      final response = await _supabase.rpc(
        'get_hot_feed',
        params: {
          'p_limit': pageSize,
          'p_offset': offset,
          if (userId != null) 'p_user_id': userId,
          'p_community_names': [communityName],
        },
      );

      return (response as List)
          .map<FeedPostModel>(
            (e) => FeedPostModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting community posts: $e');
      throw Exception('Failed to fetch community posts: $e');
    }
  }
}
