import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/widgets/vote_button.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';
import 'package:mini_reddit_v2/features/profile/presentation/pages/user_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final isCommunityAdminProvider = FutureProvider.family<bool, String>((
  ref,
  communityId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null || communityId.isEmpty) {
    return false;
  }

  final rows = await Supabase.instance.client
      .from('community_members')
      .select('role')
      .eq('community_id', communityId)
      .eq('user_id', userId)
      .limit(1);

  if (rows.isNotEmpty) {
    final role =
        Map<String, dynamic>.from(rows.first)['role']?.toString() ?? '';
    return role == 'admin';
  }

  return false;
});

class BuildCommentsSection extends ConsumerStatefulWidget {
  final List<CommentModel> comments;
  const BuildCommentsSection({super.key, required this.comments});

  @override
  ConsumerState<BuildCommentsSection> createState() =>
      _BuildCommentsSectionState();
}

class _BuildCommentsSectionState extends ConsumerState<BuildCommentsSection> {
  String? _replyingToId;
  String? _replyingToUsername;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  // لتتبع حالة إظهار/إخفاء الردود لكل تعليق
  final Map<String, bool> _showReplies = {};

  @override
  void initState() {
    super.initState();
    // افتراضياً، نضيف أول 2 ردود فقط
    for (var comment in widget.comments) {
      _showReplies[comment.id] = false; // false يعني اعرض أول 2 ردود فقط
    }
  }

  @override
  void didUpdateWidget(BuildCommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو في تعليقات جديدة، ضيفهم للـ Map
    for (var comment in widget.comments) {
      if (!_showReplies.containsKey(comment.id)) {
        _showReplies[comment.id] = false;
      }
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _toggleShowReplies(String commentId) {
    setState(() {
      _showReplies[commentId] = !(_showReplies[commentId] ?? false);
    });
  }

  void _submitReply(String postId) {
    final content = _replyController.text.trim();
    if (content.isNotEmpty && _replyingToId != null) {
      ref.read(postProvider.notifier).addComment(content, _replyingToId);
      _replyController.clear();
      setState(() {
        _replyingToId = null;
        _replyingToUsername = null;
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToUsername = null;
    });
    _replyController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final communityId = ref.watch(
      postProvider.select((state) => state.post?.communityId ?? ''),
    );
    final isCommunityAdmin = communityId.isNotEmpty
        ? ref
              .watch(isCommunityAdminProvider(communityId))
              .maybeWhen(data: (value) => value, orElse: () => false)
        : false;

    if (widget.comments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // حقل الرد المدمج (يظهر عند الرد على تعليق)
        if (_replyingToId != null) _buildReplyInputField(),

        // قائمة التعليقات
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.comments.length,
          itemBuilder: (context, index) {
            final comment = widget.comments[index];
            return _buildCommentThread(comment, 0, isCommunityAdmin);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final t = context.tokens;
    final typo = context.rTypo;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.comment_outlined, size: 48, color: t.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No comments yet',
              style: typo.titleSmall.copyWith(color: t.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Be the first to comment!',
              style: typo.bodySmall.copyWith(color: t.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInputField() {
    final postState = ref.watch(postProvider);
    final t = context.tokens;
    final typo = context.rTypo;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: t.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: t.borderFocused),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.reply, size: 16, color: t.brandOrange),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Replying to @$_replyingToUsername',
                  style: typo.labelMedium.copyWith(color: t.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: t.textSecondary),
                onPressed: _cancelReply,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  focusNode: _replyFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Write your reply...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: typo.bodyMedium.copyWith(color: t.textMuted),
                  ),
                  style: typo.bodyMedium.copyWith(color: t.textPrimary),
                  onSubmitted: (_) => _submitReply(postState.post!.id),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              postState.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: t.brandOrange,
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.send, color: t.brandOrange, size: 20),
                      onPressed: () => _submitReply(postState.post!.id),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة لعرض التعليق وكل ردوده بشكل متداخل
  Widget _buildCommentThread(CommentModel comment, int depth, bool isAdmin) {
    final showAll = _showReplies[comment.id] ?? false;
    final repliesToShow = showAll
        ? comment.replies
        : comment.replies.take(2).toList(); // أول 2 ردود فقط
    final hasMoreReplies = comment.replies.length > 2 && !showAll;

    return Column(
      children: [
        // التعليق الحالي
        _buildCommentItem(comment, depth, isAdmin),

        // الردود (إذا وجدت)
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: depth < 3 ? 24 : 12),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repliesToShow.length,
                  itemBuilder: (context, index) {
                    return _buildCommentThread(
                      repliesToShow[index],
                      depth + 1,
                      isAdmin,
                    );
                  },
                ),

                // زر عرض المزيد من الردود
                if (hasMoreReplies)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: context.tokens.divider,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                        ),
                        TextButton.icon(
                          onPressed: () => _toggleShowReplies(comment.id),
                          icon: Icon(
                            Icons.expand_more,
                            size: 16,
                            color: context.tokens.brandOrange,
                          ),
                          label: Text(
                            'Show ${comment.replies.length - 2} more ${comment.replies.length - 2 == 1 ? 'reply' : 'replies'}',
                            style: context.rTypo.labelMedium.copyWith(
                              color: context.tokens.brandOrange,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (showAll && comment.replies.length > 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: context.tokens.divider,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                        ),
                        TextButton.icon(
                          onPressed: () => _toggleShowReplies(comment.id),
                          icon: Icon(
                            Icons.expand_less,
                            size: 16,
                            color: context.tokens.textSecondary,
                          ),
                          label: Text(
                            'Hide replies',
                            style: context.rTypo.labelMedium.copyWith(
                              color: context.tokens.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment, int depth, bool isAdmin) {
    final String currentUserId = Supabase.instance.client.auth.currentUser!.id;
    final bool isReply = depth > 0;
    final t = context.tokens;
    final typo = context.rTypo;

    return Container(
      margin: EdgeInsets.only(
        left: depth > 0 ? AppSpacing.sm : AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReply)
            Container(
              width: 2,
              height: 40,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                color: t.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isReply ? t.bgElevated : t.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: t.cardBorder, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isReply ? 14 : 16,
                          backgroundColor: t.bgInput,
                          backgroundImage: comment.authorAvatarUrl != null
                              ? NetworkImage(comment.authorAvatarUrl!)
                              : null,
                          child: comment.authorAvatarUrl == null
                              ? Text(
                                  comment.authorUsername[0].toUpperCase(),
                                  style: typo.labelLarge.copyWith(
                                    fontSize: isReply ? 12 : 14,
                                    color: t.textPrimary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserProfileScreen(
                                        userId: comment.authorId,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.authorUsername,
                                      style:
                                          (isReply
                                                  ? typo.titleSmall
                                                  : typo.titleMedium)
                                              .copyWith(
                                                fontSize: isReply ? 13 : 14,
                                                color: t.textPrimary,
                                              ),
                                    ),
                                    if (isReply) const SizedBox(height: 2),
                                    Text(
                                      '@${comment.authorUsername}',
                                      style: typo.bodySmall.copyWith(
                                        color: t.textSecondary,
                                        fontSize: isReply ? 11 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(comment.createdAt),
                          style: typo.labelSmall.copyWith(
                            color: t.textMuted,
                            fontSize: isReply ? 9 : 10,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isReply ? 6 : AppSpacing.sm),

                    Text(
                      comment.content,
                      style: typo.bodyMedium.copyWith(
                        fontSize: isReply ? 13 : 14,
                        color: t.textPrimary,
                      ),
                    ),

                    SizedBox(height: isReply ? 6 : AppSpacing.sm),

                    Row(
                      children: [
                        // زر الإعجاب
                        // _buildVoteButton(
                        //   icon: comment.userVote == 1
                        //       ? Icons.arrow_upward
                        //       : Icons.arrow_upward_outlined,
                        //   count: comment.score,
                        //   isActive: comment.userVote == 1,
                        //   isSmall: isReply,
                        //   onTap: () {
                        //     ref
                        //         .read(postProvider.notifier)
                        //         .voteComment(commentId: comment.id, value: 1);
                        //   },
                        // ),
                        if (comment.authorId != currentUserId)
                          Consumer(
                            builder: (context, ref, child) {
                              final isVoting = ref.watch(
                                postProvider.select((state) => state.isVoting),
                              );

                              return CommentVoteButton(
                                comment: comment,
                                pillColor: t.bgElevated,
                                isSmall: isReply,
                                isDisabled: isVoting,
                                onUpvote: isVoting
                                    ? null
                                    : () {
                                        debugPrint(
                                          'upvote - score ${comment.score}',
                                        );
                                        ref
                                            .read(postProvider.notifier)
                                            .voteComment(
                                              commentId: comment.id,
                                              value: 1,
                                            );
                                      },
                                onDownvote: isVoting
                                    ? null
                                    : () {
                                        debugPrint(
                                          'downvote - score ${comment.score}',
                                        );
                                        ref
                                            .read(postProvider.notifier)
                                            .voteComment(
                                              commentId: comment.id,
                                              value: -1,
                                            );
                                      },
                              );
                            },
                          ),
                        SizedBox(width: isReply ? 12 : 16),

                        // زر الرد
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _replyingToId = comment.id;
                              _replyingToUsername = comment.authorUsername;
                            });
                            _replyFocusNode.requestFocus();
                          },
                          icon: Icon(
                            Icons.reply,
                            size: isReply ? 12 : 14,
                            color: t.textSecondary,
                          ),
                          label: Text(
                            'Reply',
                            style: typo.labelMedium.copyWith(
                              fontSize: isReply ? 11 : 12,
                              color: t.textSecondary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: t.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),

                        const Spacer(),

                        if (comment.authorId == currentUserId || isAdmin) ...[
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog(comment.id, context);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              size: isReply ? 14 : 16,
                            ),
                            color: t.error,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),

                    if (isReply)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right,
                              size: 12,
                              color: t.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reply',
                              style: typo.labelSmall.copyWith(
                                color: t.textMuted,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildVoteButton({
  //   required IconData icon,
  //   required int count,
  //   required bool isActive,
  //   required bool isSmall,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(16),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: isSmall ? 6 : 8,
  //         vertical: isSmall ? 2 : 4,
  //       ),
  //       decoration: BoxDecoration(
  //         color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             size: isSmall ? 14 : 16,
  //             color: isActive ? Colors.blue : Colors.grey,
  //           ),
  //           const SizedBox(width: 4),
  //           Text(
  //             count.toString(),
  //             style: TextStyle(
  //               color: isActive ? Colors.blue : Colors.grey,
  //               fontSize: isSmall ? 11 : 12,
  //               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Future<void> _showDeleteDialog(String commentId, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.bgSurface,
        title: Text('Delete comment', style: context.rTypo.titleMedium),
        content: Text(
          'Are you sure you want to delete this comment?',
          style: context.rTypo.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: context.rTypo.labelMedium.copyWith(
                color: context.tokens.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.tokens.error),
            child: Text(
              'Delete',
              style: context.rTypo.labelMedium.copyWith(
                color: context.tokens.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(postProvider.notifier).deleteComment(commentId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Comment deleted successfully'),
              backgroundColor: context.tokens.bgElevated,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: context.tokens.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
