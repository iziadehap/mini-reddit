import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/core/models/snackbar_model.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';

final savePostProvider =
    StateNotifierProvider.family<SavePostNotifier, bool, String>(
      (ref, postId) =>
          SavePostNotifier(repo: PostRepoImpl(PostDataSource()), ref: ref),
    );

class SavePostNotifier extends StateNotifier<bool> {
  final PostRepo repo;
  final Ref ref;
  SavePostNotifier({required this.repo, required this.ref}) : super(false);

  void savePost(String postId) async {
    try {
      await repo.savePost(postId);
      updateLocalState(true, postId);
    } catch (e) {
      ref.read(savePostSnackBarProvider.notifier).state = SnackBarModel(
        message: e.toString(),
        isError: true,
      );
      debugPrint('error in save post: $e');
    }
  }

  void unsavePost(String postId) async {
    try {
      await repo.unsavePost(postId);
      updateLocalState(false, postId);
    } catch (e) {
      ref.read(savePostSnackBarProvider.notifier).state = SnackBarModel(
        message: e.toString(),
        isError: true,
      );
      debugPrint('error in unsave post: $e');
    }
    updateLocalState(false, postId);
  }

  void updateLocalState(bool isSaved, String postId) {
    state = isSaved;
  }
}

final savePostSnackBarProvider = StateProvider<SnackBarModel?>((ref) {
  return null;
});
