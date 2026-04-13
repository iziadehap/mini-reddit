import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_reddit_v2/core/constants/reddit_constants.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class PostCardShareButton extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onShare;

  const PostCardShareButton({super.key, required this.post, this.onShare});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return IconButton(
      icon: Icon(Icons.share_outlined, size: 20, color: tokens.textSecondary),
      onPressed: () {
        onShare?.call();
        _showShareSheet(context);
      },
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: 'Share',
    );
  }

  void _showShareSheet(BuildContext context) {
    final tokens = context.tokens;

    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: tokens.textSecondary),
              title: Text('Copy Link', style: context.rTypo.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _copyLinkToClipboard(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: tokens.textSecondary),
              title: Text('Share via...', style: context.rTypo.bodyMedium),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _copyLinkToClipboard(BuildContext context) {
    final postLink = '${RedditConstants.postDeepLinkPrefix}${post.id}';
    Clipboard.setData(ClipboardData(text: postLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        backgroundColor: context.tokens.bgElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
