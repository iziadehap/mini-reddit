import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  Map<String, dynamic> _buildBaseParams({
    required int limit,
    required int offset,
    List<String>? communityNames,
  }) {
    return {
      'p_limit': limit,
      'p_offset': offset,
      if (_userId != null) 'p_user_id': _userId,
      if (communityNames != null && communityNames.isNotEmpty)
        'p_community_names': communityNames,
    };
  }

  Future<List<FeedPostModel>> _executeFeedRPC(
    String rpcName,
    Map<String, dynamic> params,
  ) async {
    final data = await _supabase.rpc(rpcName, params: params);

    // print('📡 Fetching $rpcName with params: $params');
    // print('📦 $rpcName response: $data');

    return (data as List)
        .map((e) => FeedPostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 🔥 HOT FEED - الأكثر تفاعلاً (عام)
  Future<List<FeedPostModel>> getHotFeed({
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    final params = _buildBaseParams(
      limit: limit,
      offset: offset,
      communityNames: communityNames,
    );

    return _executeFeedRPC('get_hot_feed', params);
  }

  /// 🆕 NEW FEED - الأحدث
  Future<List<FeedPostModel>> getNewFeed({
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    final params = _buildBaseParams(
      limit: limit,
      offset: offset,
      communityNames: communityNames,
    );

    return _executeFeedRPC('get_new_feed', params);
  }

  /// 📈 TOP FEED - الأعلى تصويتاً
  Future<List<FeedPostModel>> getTopFeed({
    required String timeframe, // 'day', 'week', 'month', 'year', 'all'
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    final params = _buildBaseParams(
      limit: limit,
      offset: offset,
      communityNames: communityNames,
    )..addAll({'p_timeframe': timeframe});

    return _executeFeedRPC('get_top_feed', params);
  }

  /// 🔍 SEARCH FEED - البحث
  Future<List<FeedPostModel>> searchPosts({
    required String query,
    int offset = 0,
    int limit = 10,
    List<String>? communityNames,
  }) async {
    final params = _buildBaseParams(
      limit: limit,
      offset: offset,
      communityNames: communityNames,
    )..addAll({'p_query': query});

    return _executeFeedRPC('search_posts', params);
  }

  /// ⭐ BEST FEED - مخصص للمستخدم (من مجتمعاته)
  Future<List<FeedPostModel>> getBestFeed({
    required String userId,
    int offset = 0,
    int limit = 10,
  }) async {
    final params = {'p_user_id': userId, 'p_limit': limit, 'p_offset': offset};

    return _executeFeedRPC('get_best_feed', params);
  }

  /// 🏆 POPULAR FEED - للزوار (بدون user_vote)
  Future<List<FeedPostModel>> getPopularFeed({
    int offset = 0,
    int limit = 10,
  }) async {
    final params = {
      'p_limit': limit,
      'p_offset': offset,
      // Note: get_popular_feed doesn't exist in new schema, get_hot_feed without p_user_id works
    };

    return _executeFeedRPC('get_hot_feed', params);
  }

  /// 👤 USER FEED - منشورات مستخدم معين
  Future<List<FeedPostModel>> getUserPosts({
    required String targetUserId,
    int offset = 0,
    int limit = 10,
  }) async {
    final params = {
      'p_target_user_id': targetUserId,
      'p_limit': limit,
      'p_offset': offset,
      if (_userId != null) 'p_current_user_id': _userId,
    };

    return _executeFeedRPC('get_user_posts', params);
  }

  /// 🏘️ COMMUNITY FEED - منشورات مجتمع معين (باستخدام hot feed)
  Future<List<FeedPostModel>> getCommunityFeed({
    required String communityName,
    int offset = 0,
    int limit = 10,
  }) async {
    return getHotFeed(
      offset: offset,
      limit: limit,
      communityNames: [communityName],
    );
  }
}
