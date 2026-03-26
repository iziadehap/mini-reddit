import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';

class BuildAddComment extends ConsumerStatefulWidget {
  final String? replyingToId;
  final String? replyingToUsername;
  final VoidCallback? onCancelReply;

  const BuildAddComment({
    super.key,
    this.replyingToId,
    this.replyingToUsername,
    this.onCancelReply,
  });

  @override
  ConsumerState<BuildAddComment> createState() => _BuildAddCommentState();
}

class _BuildAddCommentState extends ConsumerState<BuildAddComment> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.replyingToId != null) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(BuildAddComment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyingToId != null && oldWidget.replyingToId == null) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      ref
          .read(postProvider.notifier)
          .addComment(
            content,
            widget.replyingToId, // null للتعليقات العادية، معرف للردود
          );
      _commentController.clear();
      FocusScope.of(context).unfocus();
      if (widget.onCancelReply != null) {
        widget.onCancelReply!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر الرد (إذا كنا نرد على تعليق)
          if (widget.replyingToId != null && widget.replyingToUsername != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to @${widget.replyingToUsername}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onCancelReply,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // حقل الإدخال
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.replyingToId != null
                        ? 'Write your reply...'
                        : 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _submitComment(),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              postState.isLoading
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _submitComment,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
