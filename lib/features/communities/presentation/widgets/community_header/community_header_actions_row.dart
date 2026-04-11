part of '../community_header.dart';

class _AvatarAndActionsRow extends ConsumerWidget {
  final CommunityDetailsModel details;
  final CommunityModel community;
  final bool isModerator;
  final VoidCallback? onAvatarTap;

  const _AvatarAndActionsRow({
    required this.details,
    required this.community,
    required this.isModerator,
    this.onAvatarTap,
  });

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditCommunityAdminSheet(community: community),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joined = details.userStatus.isMember;
    final tokens = context.tokens;

    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -38,
            left: 0,
            child: _CommunityAvatar(
              community: community,
              tokens: tokens,
              isOwner: isModerator,
              onTap: onAvatarTap,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isModerator) ...[
                  _ModeratorBadge(tokens: tokens),
                  const SizedBox(width: AppSpacing.sm),
                  _EditButton(
                    tokens: tokens,
                    onTap: () => _openEditSheet(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                const SizedBox(width: AppSpacing.sm),
                _JoinButton(
                  joined: joined,
                  tokens: tokens,
                  onPressed: () async {
                    if (joined) {
                      await ref
                          .read(communitiesActionsProvider.notifier)
                          .leaveCommunity(community.id);
                    } else {
                      await ref
                          .read(communitiesActionsProvider.notifier)
                          .joinCommunity(community.id);
                    }

                    await ref
                        .read(communityDetailsProvider.notifier)
                        .fetchCommunityDetails(community.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
