import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/services/cash.dart' as cache_service;
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_comments_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/user_posts_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_active_in.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_active_in_sheet.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_header_slivers.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_tabs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _blocked = false;
  bool _showSearch = false;
  String _searchQuery = '';
  bool? _followOverride;
  int? _followersCountOverride;
  String? _lastLoadedId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadProfile(widget.userId),
    );
  }

  @override
  void didUpdateWidget(covariant UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _blocked = false;
      _showSearch = false;
      _searchQuery = '';
      _followOverride = null;
      _followersCountOverride = null;
      _loadProfile(widget.userId);
    }
  }

  void _loadProfile(String userId) {
    if (_lastLoadedId == userId) return;
    _lastLoadedId = userId;
    final raw = cache_service.CashService().get(cache_service.Key.blockedUsers);
    if (raw is List) _blocked = raw.map((e) => e.toString()).contains(userId);
    ref.read(profileProvider(userId).notifier).getProfile();
  }

  Future<void> _toggleBlockUser(String userId) async {
    final raw = cache_service.CashService().get(cache_service.Key.blockedUsers);
    final ids = raw is List ? raw.map((e) => e.toString()).toSet() : <String>{};
    ids.contains(userId) ? ids.remove(userId) : ids.add(userId);
    await cache_service.CashService().save(
      cache_service.Key.blockedUsers,
      ids.toList(),
    );
    if (!mounted) return;
    setState(() => _blocked = ids.contains(userId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_blocked ? 'User blocked' : 'User unblocked')),
    );
  }

  Future<void> _toggleFollow(UserProfileModel profile, bool isFollowing) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;
    try {
      await Supabase.instance.client.rpc(
        isFollowing ? 'unfollow_user' : 'follow_user',
        params: {'p_follower_id': currentUserId, 'p_following_id': profile.id},
      );
      if (!mounted) return;
      setState(() {
        _followOverride = !isFollowing;
        final base = _followersCountOverride ?? profile.followersCount;
        _followersCountOverride = isFollowing
            ? (base > 0 ? base - 1 : 0)
            : base + 1;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update follow status')),
      );
    }
  }

  Future<bool> _joinCommunity(ActiveCommunity community) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null || community.id.isEmpty) return false;
    try {
      final response = await Supabase.instance.client.rpc(
        'join_community',
        params: {'p_community_id': community.id, 'p_user_id': currentUserId},
      );
      final map = response is Map
          ? Map<String, dynamic>.from(response)
          : <String, dynamic>{};
      final success = map['success'] == true;
      final message = (map['message'] ?? '').toString().toLowerCase();
      return success || message.contains('already');
    } catch (_) {
      return false;
    }
  }

  Future<Set<String>> _fetchJoinedCommunityIds(
    List<ActiveCommunity> communities,
  ) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null || communities.isEmpty) return <String>{};

    final ids = communities
        .map((c) => c.id)
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) return <String>{};

    try {
      final data = await Supabase.instance.client
          .from('community_members')
          .select('community_id')
          .eq('user_id', currentUserId)
          .inFilter('community_id', ids);

      return data
          .map((row) => row['community_id']?.toString())
          .whereType<String>()
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _openActiveInSheet(List<ActiveCommunity> active) async {
    final joinedIds = await _fetchJoinedCommunityIds(active);
    if (!mounted) return;
    await showActiveInBottomSheet(
      context,
      active,
      onJoin: _joinCommunity,
      initialJoinedIds: joinedIds,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider(widget.userId));
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.bgPage,
      body: state.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: tokens.brandBlue)),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: context.rTypo.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ),
        data: (profile) => _buildProfile(context, profile),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, UserProfileModel profile) {
    final posts = ref
        .watch(userPostsProvider(profile.id))
        .maybeWhen(data: (list) => list, orElse: () => <FeedPostModel>[]);
    final comments = ref
        .watch(userCommentsProvider(profile.id))
        .maybeWhen(
          data: (list) => list,
          orElse: () => <UserProfileCommentItem>[],
        );
    final active = buildActiveCommunitiesFromPosts(posts);
    final isOwn = profile.id == Supabase.instance.client.auth.currentUser?.id;
    final isFollowing = _followOverride ?? profile.isFollowing;
    final followers = _followersCountOverride ?? profile.followersCount;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) =>
          buildUserProfileHeaderSlivers(
            context: context,
            profile: profile,
            blocked: _blocked,
            showSearch: _showSearch,
            isOwnProfile: isOwn,
            isFollowing: isFollowing,
            followersCount: followers,
            contributions: posts.length + comments.length,
            searchQuery: _searchQuery,
            activeCommunities: active,
            tabController: _tabController,
            onBack: () => Navigator.pop(context),
            onToggleSearch: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            }),
            onShare: () {
              Clipboard.setData(
                ClipboardData(text: 'mini-reddit://user/${profile.id}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile link copied')),
              );
            },
            onBlock: () => _toggleBlockUser(profile.id),
            onFollow: () => _toggleFollow(profile, isFollowing),
            onSearchChanged: (value) =>
                setState(() => _searchQuery = value.trim().toLowerCase()),
            onActiveInTap: () => _openActiveInSheet(active),
          ),
      body: _blocked
          ? const UserProfileBlockedView()
          : TabBarView(
              controller: _tabController,
              children: [
                UserProfilePostsTab(
                  userId: profile.id,
                  searchQuery: _searchQuery,
                ),
                UserProfileCommentsTab(
                  userId: profile.id,
                  searchQuery: _searchQuery,
                ),
                UserProfileAboutTab(
                  profile: profile,
                  followersCount: followers,
                  communities: active,
                ),
              ],
            ),
    );
  }
}
