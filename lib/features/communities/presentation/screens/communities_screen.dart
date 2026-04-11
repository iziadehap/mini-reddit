import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/fetch_communities_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/community_screen.dart';
import 'package:mini_reddit_v2/features/communities/presentation/screens/create_community.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fetchCommunitiesProvider.notifier).fetchCommunities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref
        .read(fetchCommunitiesProvider.notifier)
        .fetchCommunities(search: query.isNotEmpty ? query : null);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final communities = ref.watch(fetchCommunitiesProvider);
    final tokens = context.tokens;
    final typography = context.rTypo;

    return Scaffold(
      backgroundColor: tokens.bgCanvas,
      appBar: AppBar(
        title: Text(
          'Communities',
          style: typography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: tokens.bgSurface,
        foregroundColor: tokens.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: tokens.divider, height: 1),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: communities.when(
              data: (data) {
                return _buildCommunitiesList(data);
              },
              error: (error, stackTrace) {
                return _buildEmptyState(context);
              },
              loading: () {
                return _buildLoadingState(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: tokens.bgSurface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          color: tokens.bgInput,
          border: Border.all(color: tokens.borderDefault, width: 0.8),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search communities...',
            hintStyle: TextStyle(color: tokens.textMuted, fontSize: 14),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: tokens.textSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: tokens.textSecondary,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            filled: false,
          ),
          style: TextStyle(fontSize: 15, color: tokens.textPrimary),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.tokens.brandOrange,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final tokens = context.tokens;
    final rTypo = context.rTypo;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.reddit,
              size: 80,
              color: tokens.brandOrange.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _searchController.text.isEmpty
                  ? 'No communities yet'
                  : 'No results found',
              style: rTypo.titleLarge.copyWith(color: tokens.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _searchController.text.isEmpty
                  ? 'Be the first to create a community or try searching for another one.'
                  : 'Try a different search term to find a community.',
              style: rTypo.bodyMedium.copyWith(color: tokens.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: () => _openCreateCommunityScreen(),
                icon: const Icon(Icons.add),
                label: const Text('Create Community'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesList(List<CommunityModel> communities) {
    final tokens = context.tokens;
    final typography = context.rTypo;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        final isMember = community.isMember;

        return Material(
          color: tokens.bgSurface,
          child: Column(
            children: [
              InkWell(
                onTap: () => _navigateToCommunity(community.id, community.name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCommunityAvatar(community),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'r/${community.name}',
                                    style: typography.communityName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _formatDate(community.createdAt),
                                  style: typography.bodySmall.copyWith(
                                    color: tokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            if (community.description != null &&
                                community.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  community.description!,
                                  style: typography.bodySmall.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: tokens.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_formatNumber(community.membersCount)} members',
                                  style: typography.labelSmall.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Icon(
                                  Icons.article_outlined,
                                  size: 14,
                                  color: tokens.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatPostCount(community.postsCount),
                                  style: typography.labelSmall.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildActionButton(isMember, community.id),
                    ],
                  ),
                ),
              ),
              if (index < communities.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 76),
                  child: Divider(color: tokens.divider, height: 1),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityAvatar(CommunityModel community) {
    final tokens = context.tokens;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.bgElevated,
        border: Border.all(color: tokens.borderDefault, width: 0.8),
      ),
      child: ClipOval(
        child: community.imageUrl != null && community.imageUrl!.isNotEmpty
            ? Image.network(
                community.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarFallback(community),
              )
            : _buildAvatarFallback(community),
      ),
    );
  }

  Widget _buildAvatarFallback(CommunityModel community) {
    return Center(
      child: Text(
        community.name.isNotEmpty ? community.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: context.tokens.textPrimary,
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isMember, String communityId) {
    return SizedBox(
      width: 84,
      height: 32,
      child: isMember
          ? _buildJoinedButton(communityId)
          : _buildJoinButton(communityId),
    );
  }

  Widget _buildJoinedButton(String communityId) {
    final tokens = context.tokens;
    return OutlinedButton(
      onPressed: () => ref
          .read(communitiesActionsProvider.notifier)
          .leaveCommunity(communityId),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide(color: tokens.borderDefault, width: 1),
        foregroundColor: tokens.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      child: const Text(
        'Joined',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildJoinButton(String communityId) {
    final tokens = context.tokens;
    return ElevatedButton(
      onPressed: () => ref
          .read(communitiesActionsProvider.notifier)
          .joinCommunity(communityId),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: tokens.buttonJoin,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      child: const Text(
        'Join',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatPostCount(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M posts';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K posts';
    } else if (number == 1) {
      return '1 post';
    } else {
      return '$number posts';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToCommunity(String communityId, String communityName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityScreen(communityId: communityId),
      ),
    );
  }

  void _openCreateCommunityScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCommunityScreen()),
    );
  }
}
