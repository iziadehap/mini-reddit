import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/enum.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/user_communities_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<FeedType> getFeedType(WidgetRef ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  // 1. لو مش مسجل → Popular
  if (user == null) {
    debugPrint('👤 User not logged in → Popular feed');
    return FeedType.popular;
  }

  try {
    // 2. لو مسجل، نشوف عنده مجتمعات ولا لأ

    final response = ref.read(userCommunitiesProvider.notifier);
    await response.fetchUserCommunities();
    final communities = ref.read(userCommunitiesProvider);
    final communitiesList = communities.value;

    // final response = await supabase.rpc(
    //   'get_user_communities',
    //   params: {'p_user_id': user.id, 'p_limit': 1, 'p_offset': 0},
    // );

    // لو عنده مجتمعات → Best Feed (محتوى متخصص)
    if (communitiesList != null && communitiesList.isNotEmpty) {
      debugPrint('✅ User has communities → Best feed');
      return FeedType.best;
    }

    // 3. لو مسجد ومفيش مجتمعات → New Feed (عشان يشوف محتوى حديث)
    // بعدين نقترح عليه مجتمعات
    debugPrint('🆕 User has no communities → New feed + suggestions');
    return FeedType.newFeed;
  } catch (e) {
    debugPrint('❌ Error in whatFeedType: $e');
    // في حالة الخطأ، نرجع Popular كـ Fallback آمن
    return FeedType.popular;
  }
}
