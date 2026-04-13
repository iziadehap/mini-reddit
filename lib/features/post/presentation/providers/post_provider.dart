import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/post_state.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final postProvider = StateNotifierProvider.autoDispose<PostProvider, PostState>(
  (ref) {
    return PostProvider(
      PostRepoImpl(PostDataSource()),
      onPostUpdated: (post) {
        ref.read(feedProvider.notifier).updatePostLocally(post);
      },
    );
  },
);

class PostProvider extends StateNotifier<PostState> {
  final PostRepo _postRepo;
  final void Function(PostDetailsModel)? onPostUpdated;

  PostProvider(this._postRepo, {this.onPostUpdated})
      : super(PostState.initial());

  // ========== Getters ==========
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;
  PostDetailsModel? get _currentPost => state.post;

  // ========== Post Details ==========
  Future<void> getPostDetails({required String postId}) async {
    _clearError();
    _setLoading();

    if (_userId == null) {
      _setError('User not logged in', showFullScreen: true);
      return;
    }

    final result = await _postRepo.getPostDetails(
      postId: postId,
      userId: _userId!,
    );

    result.fold(
      (failure) => _setError(failure.toString(), showFullScreen: true),
      (postDetails) {
        state = state.copyWith(post: postDetails, isLoading: false);
        onPostUpdated?.call(postDetails);
      },
    );
  }

  Future<List<String>?> createPost({
    required String communityId,
    required String title,
    required String content,
    String? flairId,
    List<File>? imageFiles,
  }) async {
    List<String>? imageUrls;

    if (imageFiles != null && imageFiles.isNotEmpty) {
      final result = await _postRepo.uploadPostImage(imageFiles);
      result.fold((failure) => _setError(failure.toString()), (urls) {
        imageUrls = urls;
      });
    }
    return imageUrls;
  }

  // ========== Post Voting ==========
  Future<void> votePost({required String postId, required int value}) async {
    if (_currentPost == null || _currentPost!.id != postId) return;
    if (state.isVoting) {
      debugPrint('⏳ Already voting, ignoring...');
      return;
    }
    if (_userId == null) {
      _setError('User not logged in');
      return;
    }

    // حفظ الحالة الأصلية
    final originalPost = _currentPost;

    // تطبيق التحديث المحلي
    _applyLocalPostVote(value);
    state = state.copyWith(isVoting: true);

    debugPrint('📤 vote post: $postId value: $value');

    final result = await _postRepo.votePost(
      userId: _userId!,
      postId: postId,
      value: value,
    );

    result.fold(
      (failure) {
        debugPrint('❌ vote post failed: $failure');
        // التراجع عن التحديث المحلي
        state = state.copyWith(post: originalPost, isVoting: false);
        if (originalPost != null) onPostUpdated?.call(originalPost);
        _setError(failure.toString());
      },
      (success) {
        debugPrint('✅ vote post success!');

        if (success.data != null && success.data!['new_score'] != null) {
          final newScore = (success.data!['new_score'] as num).toInt();
          final newValue = (success.data!['value'] as num?)?.toInt() ?? 0;
          _applyServerPostVote(newScore, newValue);
        } else {
          state = state.copyWith(isVoting: false);
        }
      },
    );
  }

  void _applyLocalPostVote(int value) {
    if (_currentPost == null) return;

    final post = _currentPost!;
    int newScore;
    int? newUserVote;

    if (post.userVote == value) {
      newScore = post.score - post.userVote!;
      newUserVote = null;
    } else if (post.userVote == null) {
      newScore = post.score + value;
      newUserVote = value;
    } else {
      newScore = post.score + (value * 2);
      newUserVote = value;
    }

    final updatedPost = post.copyWith(
      score: newScore,
      userVote: newUserVote,
      clearUserVote: newUserVote == null,
    );
    state = state.copyWith(post: updatedPost);
    onPostUpdated?.call(updatedPost);
  }

  void _applyServerPostVote(int newScore, int newUserVote) {
    if (_currentPost == null) return;

    final updatedPost = _currentPost!.copyWith(
      score: newScore,
      userVote: newUserVote == 0 ? null : newUserVote,
      clearUserVote: newUserVote == 0,
    );

    state = state.copyWith(post: updatedPost, isVoting: false);
    onPostUpdated?.call(updatedPost);
  }

  // ========== Comments ==========
  Future<void> addComment(String content, String? parentId) async {
    if (_currentPost == null) return;
    _clearError();

    if (_userId == null) {
      _setError('User not logged in');
      return;
    }

    if (content.trim().isEmpty) {
      _setError('Comment cannot be empty');
      return;
    }

    final result = await _postRepo.addComment(
      postId: _currentPost!.id,
      content: content,
      userId: _userId!,
      parentId: parentId,
    );

    result.fold(
      (failure) => _setError(failure.toString()),
      (_) => _refreshCurrentPost(),
    );
  }

  Future<void> deleteComment(String commentId) async {
    if (_userId == null) {
      _setError('User not logged in');
      return;
    }

    final result = await _postRepo.deleteComment(
      commentId: commentId,
      userId: _userId!,
    );

    result.fold(
      (failure) => _setError(failure.toString()),
      (_) => _refreshCurrentPost(),
    );
  }

  // ========== Comment Voting ==========
  Future<void> voteComment({
    required String commentId,
    required int value,
  }) async {
    if (state.isVoting) {
      debugPrint('⏳ Already voting, ignoring...');
      return;
    }
    if (_userId == null) {
      _setError('User not logged in');
      return;
    }

    final originalPost = _currentPost;
    _applyLocalCommentVote(commentId, value);
    state = state.copyWith(isVoting: true);

    debugPrint('📤 vote comment: $commentId value: $value');

    final result = await _postRepo.voteComment(
      userId: _userId!,
      commentId: commentId,
      value: value,
    );

    result.fold(
      (failure) {
        debugPrint('❌ vote failed: $failure');
        state = state.copyWith(post: originalPost, isVoting: false);
        _setError(failure.toString());
      },
      (success) {
        debugPrint('✅ vote success!');

        // ✅ استخدام success.data بدلاً من response.data
        if (success.data != null) {
          _applyServerCommentVote(commentId, success.data!);
        }
        state = state.copyWith(isVoting: false);
      },
    );
  }

  void _applyLocalCommentVote(String commentId, int value) {
    if (_currentPost == null) return;

    final updatedPost = _currentPost!.copyWith(
      comments: _updateCommentVoteLocally(
        _currentPost!.comments,
        commentId,
        value,
      ),
    );
    state = state.copyWith(post: updatedPost);
  }

  List<CommentModel> _updateCommentVoteLocally(
    List<CommentModel> comments,
    String commentId,
    int value,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        int newScore;
        int? newUserVote;

        if (comment.userVote == value) {
          newScore = comment.score - comment.userVote!;
          newUserVote = null;
        } else if (comment.userVote == null) {
          newScore = comment.score + value;
          newUserVote = value;
        } else {
          newScore = comment.score + (value * 2);
          newUserVote = value;
        }

        return comment.copyWith(score: newScore, userVote: newUserVote);
      }

      if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _updateCommentVoteLocally(comment.replies, commentId, value),
        );
      }
      return comment;
    }).toList();
  }

  void _applyServerCommentVote(
    String commentId,
    Map<String, dynamic> response,
  ) {
    if (_currentPost == null) return;

    final action = response['action'] as String? ?? 'added';
    final serverValue = response['value'] as int? ?? 0;

    final updatedPost = _currentPost!.copyWith(
      comments: _applyServerCommentUpdate(
        _currentPost!.comments,
        commentId,
        serverValue,
        action,
      ),
    );

    state = state.copyWith(post: updatedPost);
  }

  List<CommentModel> _applyServerCommentUpdate(
    List<CommentModel> comments,
    String commentId,
    int serverValue,
    String action,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        int? newUserVote = comment.userVote;

        switch (action) {
          case 'added':
            newUserVote = serverValue;
            break;
          case 'removed':
            newUserVote = null;
            break;
          case 'changed':
            newUserVote = serverValue;
            break;
        }

        return comment.copyWith(userVote: newUserVote);
      }

      if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _applyServerCommentUpdate(
            comment.replies,
            commentId,
            serverValue,
            action,
          ),
        );
      }
      return comment;
    }).toList();
  }

  // ========== Utilities ==========
  void resetSnackBarFlag() {
    state = state.copyWith(isSnackBarShown: true);
  }

  void clearData() {
    state = PostState.initial();
  }

  // ========== Error Handling ==========
  void _setLoading() => state = state.copyWith(isLoading: true);

  void _setError(String message, {bool showFullScreen = false}) {
    final error = showFullScreen
        ? PostError.fullScreen(message, onAction: () => _refreshCurrentPost())
        : PostError.snackBar(message);

    state = state.copyWith(
      error: error,
      isLoading: false,
      isSnackBarShown: false,
    );
  }

  void _clearError() =>
      state = state.copyWith(error: null, isSnackBarShown: false);

  Future<void> _refreshCurrentPost() {
    if (_currentPost != null) {
      return getPostDetails(postId: _currentPost!.id);
    }
    return Future.value();
  }
}
