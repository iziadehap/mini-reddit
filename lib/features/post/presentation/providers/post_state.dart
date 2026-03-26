import 'dart:ui';

import 'package:mini_reddit_v2/core/models/models.dart';

class PostState {
  final bool isLoading;
  final PostDetailsModel? post;
  final PostError? error;
  final bool isSnackBarShown;
  final bool isVoting; // ← جديد

  PostState({
    required this.isLoading,
    this.post,
    this.error,
    this.isSnackBarShown = false,
    this.isVoting = false, // ← جديد
  });

  PostState copyWith({
    bool? isLoading,
    PostDetailsModel? post,
    PostError? error,
    bool? isSnackBarShown,
    bool? isVoting, // ← جديد
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      post: post ?? this.post,
      error: error ?? this.error,
      isSnackBarShown: isSnackBarShown ?? this.isSnackBarShown,
      isVoting: isVoting ?? this.isVoting, // ← جديد
    );
  }

  factory PostState.initial() => PostState(
    isLoading: false,
    post: null,
    error: null,
    isSnackBarShown: false,
    isVoting: false, // ← جديد
  );

  // حالات مساعدة
  bool get hasError => error != null;
  bool get showFullScreenError => error?.showFullScreen ?? false;
  String? get errorMessage => error?.message;
}

// فصل الـ Error في كلاس منفصل
class PostError {
  final String message;
  final bool showFullScreen; // true = شاشة كاملة، false = SnackBar
  final String? actionLabel; // نص زر الإجراء (مثل "إعادة المحاولة")
  final VoidCallback? onAction; // الإجراء عند الضغط

  PostError({
    required this.message,
    this.showFullScreen = false,
    this.actionLabel,
    this.onAction,
  });

  // للـ SnackBar errors
  factory PostError.snackBar(String message) {
    return PostError(message: message, showFullScreen: false);
  }

  // للـ Full screen errors
  factory PostError.fullScreen(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return PostError(
      message: message,
      showFullScreen: true,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
