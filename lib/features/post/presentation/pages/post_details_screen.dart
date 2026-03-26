import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/widgets/error_widgets.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_state.dart';
import 'package:mini_reddit_v2/features/post/presentation/widgets/build_add_comment.dart';
import 'package:mini_reddit_v2/features/post/presentation/widgets/build_commints.dart';
import 'package:mini_reddit_v2/features/post/presentation/widgets/post_card.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ الطريقة الصحيحة: استخدام addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(postProvider.notifier).getPostDetails(postId: widget.postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);

    // ✅ كمان هنا نستخدم addPostFrameCallback للـ SnackBar
    ref.listen(postProvider, (previous, next) {
      if (next.hasError && !next.showFullScreenError && !next.isSnackBarShown) {
        // تأخير ظهور SnackBar بعد انتهاء البناء
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Error'),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );

          // تحديث حالة الـ SnackBar
          ref.read(postProvider.notifier).resetSnackBarFlag();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: _buildBody(postState),
    );
  }

  Widget _buildBody(PostState state) {
    ref.listen(postProvider, (previous, next) {
      // للأخطاء العادية اللي محتاجة SnackBar
      if (next.hasError && !next.showFullScreenError && !next.isSnackBarShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Error'),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );

          // تحديث الحالة بعد ظهور SnackBar
          ref.read(postProvider.notifier).resetSnackBarFlag();
        });
      }
    });
    // حالة التحميل الأولي
    if (state.isLoading && state.post == null) {
      return const LoadingWidget(message: 'Loading post...');
    }

    // حالة الخطأ full screen
    if (state.showFullScreenError) {
      return ErrorWidgetCustom(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: () {
          // إعادة المحاولة - برضو داخل addPostFrameCallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref
                  .read(postProvider.notifier)
                  .getPostDetails(postId: widget.postId);
            }
          });
        },
      );
    }

    // حالة عدم وجود بوست
    if (state.post == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Post not found', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    // العرض العادي
    return RefreshIndicator(
      onRefresh: () async {
        // RefreshIndicator أصلاً بيعمل async
        await ref
            .read(postProvider.notifier)
            .getPostDetails(postId: widget.postId);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            PostCard(
              post: state.post!,
              onUpvote: () {
                ref
                    .read(postProvider.notifier)
                    .votePost(postId: state.post!.id, value: 1);
              },
              onDownvote: () {
                ref
                    .read(postProvider.notifier)
                    .votePost(postId: state.post!.id, value: -1);
              },
            ),
            const Divider(height: 1),
            BuildAddComment(),
            BuildCommentsSection(comments: state.post!.comments),
          ],
        ),
      ),
    );
  }
}
