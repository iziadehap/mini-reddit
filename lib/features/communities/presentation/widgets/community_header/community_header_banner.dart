part of '../community_header.dart';

class _CommunityBanner extends StatelessWidget {
  final CommunityModel community;
  final bool isOwner;
  final VoidCallback? onTap;

  const _CommunityBanner({
    required this.community,
    this.isOwner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bannerUrl = community.bannerUrl;
    return GestureDetector(
      onTap: isOwner ? onTap : null,
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: bannerUrl != null && bannerUrl.isNotEmpty
            ? Image.network(
                bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _defaultBanner(context),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _defaultBanner(context);
                },
              )
            : _defaultBanner(context),
      ),
    );
  }

  Widget _defaultBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.tokens.brandOrangeDark,
            context.tokens.brandOrange,
            context.tokens.brandOrangeLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
