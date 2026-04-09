import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/features/profile/presentation/widgets/user_profile/user_profile_active_in.dart';

Future<void> showActiveInBottomSheet(
  BuildContext context,
  List<ActiveCommunity> communities, {
  Future<bool> Function(ActiveCommunity community)? onJoin,
  Set<String> initialJoinedIds = const <String>{},
}) {
  final tokens = context.tokens;
  final typo = context.rTypo;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final joiningIds = <String>{};
      final joinedIds = <String>{...initialJoinedIds};

      return StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(sheetContext).size.height * 0.7,
          decoration: BoxDecoration(
            color: tokens.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Active in',
                        style: typo.titleLarge.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tokens.bgElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: tokens.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Some communities may be hidden due to their private status.',
                  style: typo.bodyMedium.copyWith(color: tokens.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  itemCount: communities.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (itemContext, index) {
                    final community = communities[index];
                    final isJoining = joiningIds.contains(community.id);
                    final isJoined = joinedIds.contains(community.id);
                    final canJoin = community.id.isNotEmpty;
                    final hasImage = (community.imageUrl ?? '')
                        .trim()
                        .isNotEmpty;

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: tokens.bgElevated,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: tokens.borderDefault),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: tokens.bgInput,
                            backgroundImage: hasImage
                                ? NetworkImage(community.imageUrl!)
                                : null,
                            child: hasImage
                                ? null
                                : Icon(
                                    Icons.group,
                                    color: tokens.textSecondary,
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'r/${community.name}',
                                  style: typo.titleMedium.copyWith(
                                    color: tokens.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${community.postsCount} posts by this user',
                                  style: typo.bodyMedium.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Active community where this user posts and comments.',
                                  style: typo.bodySmall.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: isJoined || isJoining
                                  ? null
                                  : !canJoin
                                  ? null
                                  : () async {
                                      if (onJoin == null) return;
                                      setSheetState(() {
                                        joiningIds.add(community.id);
                                      });
                                      final success = await onJoin(community);
                                      if (!itemContext.mounted) return;
                                      setSheetState(() {
                                        joiningIds.remove(community.id);
                                        if (success) {
                                          joinedIds.add(community.id);
                                        }
                                      });
                                      ScaffoldMessenger.of(
                                        itemContext,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Joined r/${community.name}'
                                                : 'Could not join r/${community.name}',
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens.buttonJoin,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                              ),
                              child: Text(
                                isJoined
                                    ? 'Joined'
                                    : (isJoining ? 'Joining...' : 'Join'),
                                style: typo.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
