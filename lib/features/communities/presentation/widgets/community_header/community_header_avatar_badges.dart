part of '../community_header.dart';

class _CommunityAvatar extends StatelessWidget {
  final CommunityModel community;
  final RedditTokens tokens;
  final bool isOwner;
  final VoidCallback? onTap;

  const _CommunityAvatar({
    required this.community,
    required this.tokens,
    this.isOwner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = community.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: isOwner ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tokens.bgSurface, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 38,
          backgroundColor: tokens.brandOrange,
          backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
          child: hasImage
              ? null
              : Text(
                  community.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ModeratorBadge extends StatelessWidget {
  final RedditTokens tokens;

  const _ModeratorBadge({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: tokens.brandOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: tokens.brandOrange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 12, color: tokens.brandOrange),
          const SizedBox(width: 4),
          Text(
            'MOD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: tokens.brandOrange,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
