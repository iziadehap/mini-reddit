import 'package:flutter/material.dart';
import 'package:mini_reddit_v2/core/models/feed_post.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class ActiveCommunity {
  final String id;
  final String name;
  final String? imageUrl;
  final int postsCount;

  const ActiveCommunity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.postsCount,
  });

  ActiveCommunity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? postsCount,
  }) {
    return ActiveCommunity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}

List<ActiveCommunity> buildActiveCommunitiesFromPosts(
  List<FeedPostModel> posts,
) {
  final byCommunity = <String, ActiveCommunity>{};
  for (final post in posts) {
    final name = post.communityName.trim();
    if (name.isEmpty) {
      continue;
    }
    final key = post.communityId.isNotEmpty ? post.communityId : name;
    final current = byCommunity[key];
    if (current == null) {
      byCommunity[key] = ActiveCommunity(
        id: key,
        name: name,
        imageUrl: post.communityImageUrl,
        postsCount: 1,
      );
    } else {
      byCommunity[key] = current.copyWith(postsCount: current.postsCount + 1);
    }
  }

  final list = byCommunity.values.toList()
    ..sort((a, b) => b.postsCount.compareTo(a.postsCount));
  return list;
}

class ActiveInSummaryRow extends StatelessWidget {
  final List<ActiveCommunity> communities;

  const ActiveInSummaryRow({super.key, required this.communities});

  @override
  Widget build(BuildContext context) {
    if (communities.isEmpty) {
      return const SizedBox.shrink();
    }
    final tokens = context.tokens;
    final typo = context.rTypo;
    final first = communities.first;
    final others = communities.length - 1;

    return Row(
      children: [
        Icon(Icons.reddit, color: tokens.brandOrange, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            others > 0 ? 'r/${first.name} and $others more' : 'r/${first.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.titleSmall.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Icon(Icons.chevron_right, color: tokens.textSecondary),
      ],
    );
  }
}

class ActiveInStatCell extends StatelessWidget {
  final List<ActiveCommunity> communities;
  final VoidCallback onTap;

  const ActiveInStatCell({
    super.key,
    required this.communities,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typo = context.rTypo;

    return InkWell(
      onTap: communities.isEmpty ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (communities.isEmpty)
            Text(
              '0',
              style: typo.titleLarge.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            SizedBox(
              height: 22,
              child: Stack(
                children: List.generate(
                  communities.length > 3 ? 3 : communities.length,
                  (index) {
                    final item = communities[index];
                    final hasImage = (item.imageUrl ?? '').trim().isNotEmpty;
                    return Positioned(
                      left: index * 14,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: tokens.bgElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tokens.bgSurface,
                            width: 1.5,
                          ),
                          image: hasImage
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasImage
                            ? null
                            : Icon(
                                Icons.group,
                                size: 11,
                                color: tokens.textSecondary,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Text(
                'Active In',
                style: typo.bodySmall.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, color: tokens.textSecondary, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}
