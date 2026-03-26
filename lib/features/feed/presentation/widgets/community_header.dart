import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/utils/time_formatter.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';

class CommunityHeader extends ConsumerWidget {
  final CommunityModel community;

  const CommunityHeader({super.key, required this.community});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(children: [_buildBanner(), _buildInfo(context, ref)]),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 80,
      width: double.infinity,
      color: RedditConstants.orange,
      child: null,
    );
  }

  Widget _buildInfo(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -20),
            child: _buildAvatar(context),
          ),
          const SizedBox(height: 8),
          _buildCommunityDetails(context, ref),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 30,
        backgroundImage: community.imageUrl != null
            ? NetworkImage(community.imageUrl!)
            : null,
        child: community.imageUrl == null
            ? Text(
                community.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCommunityDetails(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'r/${community.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${TimeFormatter.formatNumber(community.membersCount)} members',
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _buildJoinButton(context, ref),
          ],
        ),
        if (community.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          Text(community.description!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildJoinButton(BuildContext context, WidgetRef ref) {
    if (community.id.isEmpty) return const SizedBox.shrink();

    final bool joined = community.isMember;

    return OutlinedButton(
      onPressed: () {
        if (joined) {
          ref
              .read(communitiesActionsProvider.notifier)
              .leaveCommunity(community.id);
        } else {
          ref
              .read(communitiesActionsProvider.notifier)
              .joinCommunity(community.id);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: joined ? Colors.grey : RedditConstants.orange,
        side: BorderSide(
          color: joined ? Colors.grey : RedditConstants.orange,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(80, 36),
      ),
      child: Text(
        joined ? 'Joined' : 'Join',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
