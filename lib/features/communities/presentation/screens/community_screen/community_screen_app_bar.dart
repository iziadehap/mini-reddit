part of '../community_screen.dart';

extension _CommunityScreenAppBar on _CommunityScreenState {
  Widget _buildAppBar(
    BuildContext context,
    AsyncValue<CommunityDetailsModel> detailsState,
    RedditTokens tokens,
  ) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: tokens.bgSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: AnimatedOpacity(
        opacity: _showStickyTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 180),
        child: Row(
          children: [
            detailsState.whenOrNull(
                  data: (details) {
                    final community = details.community;
                    if (community == null) return null;
                    return CircleAvatar(
                      radius: 14,
                      backgroundColor: tokens.brandOrange,
                      backgroundImage: community.imageUrl != null
                          ? NetworkImage(community.imageUrl!)
                          : null,
                      child: community.imageUrl == null
                          ? Text(
                              community.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    );
                  },
                ) ??
                const SizedBox.shrink(),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'r/${widget.communityId}',
                style: context.rTypo.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<CommunityDetailsModel> detailsState) {
    return detailsState.when(
      data: (details) =>
          SliverToBoxAdapter(child: CommunityHeader(details: details)),
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SkeletonLoader(height: 160),
        ),
      ),
      error: (err, _) => SliverToBoxAdapter(
        child: ErrorWidgetCustom(
          message: 'Failed to load community: $err',
          onRetry: _fetchData,
        ),
      ),
    );
  }
}
