import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
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
            widget.replyingToId,
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
    final t = context.tokens;
    final typo = context.rTypo;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
      borderSide: BorderSide(color: t.borderDefault),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: t.bgSurface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: t.bgOverlay.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyingToId != null && widget.replyingToUsername != null)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: t.bgElevated,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: t.borderFocused),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: t.brandOrange),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Replying to @${widget.replyingToUsername}',
                      style: typo.labelMedium.copyWith(color: t.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: t.textSecondary),
                    onPressed: widget.onCancelReply,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  style: typo.bodyMedium.copyWith(color: t.textPrimary),
                  decoration: InputDecoration(
                    hintText: widget.replyingToId != null
                        ? 'Write your reply...'
                        : 'Add a comment...',
                    filled: true,
                    fillColor: t.bgInput,
                    border: border,
                    enabledBorder: border,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      borderSide:
                          BorderSide(color: t.borderFocused, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 10,
                    ),
                    hintStyle:
                        typo.bodyMedium.copyWith(color: t.textSecondary),
                  ),
                  onSubmitted: (_) => _submitComment(),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              postState.isLoading
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: t.brandOrange,
                        ),
                      ),
                    )
                  : Material(
                      color: t.brandOrange,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.send, color: t.buttonPrimaryText),
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
