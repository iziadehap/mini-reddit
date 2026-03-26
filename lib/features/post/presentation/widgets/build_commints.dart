import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/widgets/vote_button.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            return _buildCommentThread(comment, 0);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No comments yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Be the first to comment!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInputField() {
    final postState = ref.watch(postProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.reply, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Replying to @$_replyingToUsername',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: _cancelReply,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  focusNode: _replyFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Write your reply...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) => _submitReply(postState.post!.id),
                ),
              ),
              const SizedBox(width: 8),
              postState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => _submitReply(postState.post!.id),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة لعرض التعليق وكل ردوده بشكل متداخل
  Widget _buildCommentThread(CommentModel comment, int depth) {
    final showAll = _showReplies[comment.id] ?? false;
    final repliesToShow = showAll
        ? comment.replies
        : comment.replies.take(2).toList(); // أول 2 ردود فقط
    final hasMoreReplies = comment.replies.length > 2 && !showAll;

    return Column(
      children: [
        // التعليق الحالي
        _buildCommentItem(comment, depth),

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
                    return _buildCommentThread(repliesToShow[index], depth + 1);
                  },
                ),

                // زر عرض المزيد من الردود
                if (hasMoreReplies)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        TextButton.icon(
                          onPressed: () => _toggleShowReplies(comment.id),
                          icon: Icon(
                            Icons.expand_more,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          label: Text(
                            'Show ${comment.replies.length - 2} more ${comment.replies.length - 2 == 1 ? 'reply' : 'replies'}',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),

                // زر إخفاء الردود (إذا كنا بنعرض الكل)
                if (showAll && comment.replies.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        TextButton.icon(
                          onPressed: () => _toggleShowReplies(comment.id),
                          icon: Icon(
                            Icons.expand_less,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          label: Text(
                            'Hide replies',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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

  Widget _buildCommentItem(CommentModel comment, int depth) {
    final String currentUserId = Supabase.instance.client.auth.currentUser!.id;
    final bool isReply = depth > 0; // تحديد إذا كان هذا رد

    return Container(
      margin: EdgeInsets.only(
        left: depth > 0 ? 8.0 : 16.0,
        right: 16.0,
        top: 4.0,
        bottom: 4.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الخط الجانبي للردود
          if (isReply)
            Container(
              width: 2,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isReply ? Colors.grey[50] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(isReply ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الكاتب
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isReply ? 14 : 16,
                          backgroundImage: comment.authorAvatarUrl != null
                              ? NetworkImage(comment.authorAvatarUrl!)
                              : null,
                          child: comment.authorAvatarUrl == null
                              ? Text(
                                  comment.authorUsername[0].toUpperCase(),
                                  style: TextStyle(fontSize: isReply ? 12 : 14),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.authorUsername,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isReply ? 13 : 14,
                                  color: isReply
                                      ? Colors.grey[800]
                                      : Colors.black,
                                ),
                              ),
                              if (isReply) const SizedBox(height: 2),
                              Text(
                                '@${comment.authorUsername}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isReply ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // التاريخ
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: isReply ? 9 : 10,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isReply ? 6 : 8),

                    // محتوى التعليق
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: isReply ? 13 : 14,
                        color: isReply ? Colors.grey[800] : Colors.black,
                      ),
                    ),

                    SizedBox(height: isReply ? 6 : 8),

                    // أزرار التفاعل
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
                                pillColor: Colors.grey[200]!,
                                isSmall: isReply,
                                isDisabled: isVoting,
                                onUpvote: isVoting
                                    ? null
                                    : () {
                                        print(
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
                                        print(
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
                          icon: Icon(Icons.reply, size: isReply ? 12 : 14),
                          label: Text(
                            'Reply',
                            style: TextStyle(fontSize: isReply ? 11 : 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),

                        const Spacer(),

                        // زر الحذف للمستخدم الحالي
                        if (comment.authorId == currentUserId) ...[
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog(comment.id, context);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              size: isReply ? 14 : 16,
                            ),
                            color: Colors.red[300],
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),

                    // مؤشر "رد" صغير للتمييز
                    if (isReply)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.grey[400],
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
        title: const Text('Delete comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Implement delete comment
      ref.read(postProvider.notifier).deleteComment(commentId);
      print('Delete comment: $commentId');
    }
  }
}
