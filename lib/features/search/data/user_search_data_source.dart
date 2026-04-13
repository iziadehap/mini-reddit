import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSearchDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserProfileModel>> searchUsers({
    required String query,
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _supabase.rpc(
      'search_users',
      params: {
        'p_query': query,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    return (data as List)
        .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
