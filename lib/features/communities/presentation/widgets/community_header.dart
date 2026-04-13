import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/community_details_provider.dart';
import 'package:mini_reddit_v2/features/communities/presentation/widgets/edit_community_admin_sheet.dart';
import 'package:mini_reddit_v2/features/communities/presentation/widgets/community_header/community_photo_picker.dart';

part 'community_header/community_header_banner.dart';
part 'community_header/community_header_actions_row.dart';
part 'community_header/community_header_avatar_badges.dart';
part 'community_header/community_header_buttons.dart';
part 'community_header/community_header_info.dart';

class CommunityHeader extends ConsumerWidget {
  final CommunityDetailsModel details;

  const CommunityHeader({super.key, required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = details.community;
    if (community == null) return const SizedBox.shrink();
    final isOwner = details.userStatus.isAdmin;

    return Container(
      color: context.tokens.bgSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommunityBanner(
            community: community,
            isOwner: isOwner,
            onTap: isOwner ? () => _showBannerOptions(context, ref) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AvatarAndActionsRow(
                  details: details,
                  community: community,
                  isModerator: isOwner,
                  onAvatarTap: isOwner
                      ? () => _showAvatarOptions(context, ref)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                _CommunityTitleSection(community: community),
                const SizedBox(height: AppSpacing.xs),
                _CommunityStats(details: details),
                if (community.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.md),
                  _CommunityDescription(community: community),
                ],
                const SizedBox(height: AppSpacing.md),
                _CommunityTags(community: community),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarOptions(BuildContext context, WidgetRef ref) async {
    final community = details.community;
    if (community == null) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.tokens.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.tokens.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Profile Photo', style: context.rTypo.titleMedium),
              const SizedBox(height: AppSpacing.xl),
              ListTile(
                leading: Icon(Icons.edit, color: context.tokens.brandOrange),
                title: const Text('Change Photo'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  try {
                    final file = await CommunityPhotoPicker.pickImage(context);
                    if (file != null && context.mounted) {
                      await ref
                          .read(communitiesActionsProvider.notifier)
                          .updateCommunityImage(
                            community.id,
                            community.name,
                            file,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile photo updated!'),
                            backgroundColor: context.tokens.success,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: context.tokens.error,
                        ),
                      );
                    }
                  }
                },
              ),
              if (community.imageUrl != null)
                ListTile(
                  leading: Icon(Icons.delete, color: context.tokens.error),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: context.tokens.error),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    try {
                      await ref
                          .read(communitiesActionsProvider.notifier)
                          .deleteCommunityImage(community.id, community.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile photo removed!'),
                            backgroundColor: context.tokens.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: context.tokens.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBannerOptions(BuildContext context, WidgetRef ref) async {
    final community = details.community;
    if (community == null) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.tokens.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.tokens.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Banner', style: context.rTypo.titleMedium),
              const SizedBox(height: AppSpacing.xl),
              ListTile(
                leading: Icon(Icons.edit, color: context.tokens.brandOrange),
                title: const Text('Change Banner'),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  try {
                    final file = await CommunityPhotoPicker.pickImage(context);
                    if (file != null && context.mounted) {
                      await ref
                          .read(communitiesActionsProvider.notifier)
                          .updateCommunityBanner(
                            community.id,
                            community.name,
                            file,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Banner updated!'),
                            backgroundColor: context.tokens.success,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: context.tokens.error,
                        ),
                      );
                    }
                  }
                },
              ),
              if (community.bannerUrl != null)
                ListTile(
                  leading: Icon(Icons.delete, color: context.tokens.error),
                  title: Text(
                    'Remove Banner',
                    style: TextStyle(color: context.tokens.error),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    try {
                      await ref
                          .read(communitiesActionsProvider.notifier)
                          .deleteCommunityBanner(community.id, community.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Banner removed!'),
                            backgroundColor: context.tokens.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: context.tokens.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
