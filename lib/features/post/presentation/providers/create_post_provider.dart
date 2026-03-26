import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';

final createPostProvider =
    StateNotifierProvider<CreatePostProvider, AsyncValue>((ref) {
      return CreatePostProvider(
        ref: ref,
        postRepo: PostRepoImpl(PostDataSource()),
      );
    });

class CreatePostProvider extends StateNotifier<AsyncValue> {
  final Ref ref;
  final PostRepo _postRepo;
  CreatePostProvider({required this.ref, required PostRepo postRepo})
    : _postRepo = postRepo,
      super(const AsyncValue.data(null));

  Future<void> createPost({
    required String communityId,
    required String title,
    required String content,
    String? flairId,
    List<File>? imageFiles,
  }) async {
    state = const AsyncValue.loading();
    List<String>? imageUrls;
    bool isImagesUploaded = false;
    if (imageFiles != null) {
      imageUrls = await _uplodePostImage(imageFiles);
      if (imageUrls != null && imageUrls.isNotEmpty) {
        isImagesUploaded = true;
      }
    }

    if (isImagesUploaded) {
      await _createPost(
        communityId: communityId,
        title: title,
        content: content,
        flairId: flairId,
        imageUrls: imageUrls,
      );
    } else {
      setError("Failed to upload images", StackTrace.current);
    }
  }

  Future<List<String>?> _uplodePostImage(List<File> imageFiles) async {
    List<String>? imageUrls;
    final data = await _postRepo.uploadPostImage(imageFiles);
    data.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (urls) {
        imageUrls = urls;
      },
    );
    return imageUrls;
  }

  Future<void> _createPost({
    required String communityId,
    required String title,
    required String content,
    String? flairId,
    List<String>? imageUrls,
  }) async {
    final result = await _postRepo.createPost(
      communityId: communityId,
      title: title,
      content: content,
      flairId: flairId,
      imageUrls: (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls : null,
    );
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (post) {
        state = AsyncValue.data(post);
        setSnackbarSuccess("Post created successfully");
        // final currentFeed = state.value ?? [];
        // state = AsyncValue.data([post, ...currentFeed]);
      },
    );
  }
  // Future<void> createCommunityPost({
  //   required String communityId,
  //   required String title,
  //   required String content,
  //   String? flairId,
  //   List<String>? imageUrls,
  // }) async {
  //   String postType = 'text';
  //   if (imageUrls != null && imageUrls.isNotEmpty) {
  //     postType = 'image';
  //   }
  //   setLoading();
  //   final result = await communitiesRepo.createPostInCommunity(
  //     communityId: communityId,
  //     title: title,
  //     content: content,
  //     imageUrls: imageUrls,
  //     postType: postType,
  //     flairId: flairId,
  //   );
  //
  //   result.fold((failure) => setError(failure.message), (newPost) {
  //     final currentFeed = state.value ?? [];
  //     state = AsyncValue.data([newPost, ...currentFeed]);
  //   });
  // }
  //
  // Future<List<String>> uploadPostImage(List<File> imageFiles) async {
  //   final result = await postRepo.uploadPostImage(imageFiles);
  //   return result.fold((failure) {
  //     state = state.copyWith(error: failure.message);
  //     return [];
  //   }, (urls) => urls);
  // }

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setError(String message, StackTrace stackTrace) {
    setSnackbarError(message);
    state = AsyncValue.error(message, stackTrace);
  }

  void setSnackbarError(String message) {
    ref.read(createPostSnackbarProvider.notifier).state = SnackbarState(
      message: message,
      isError: true,
    );
  }

  void setSnackbarSuccess(String message) {
    ref.read(createPostSnackbarProvider.notifier).state = SnackbarState(
      message: message,
      isError: false,
    );
  }
}

// !! this provider is for snackbar only

final createPostSnackbarProvider = StateProvider<SnackbarState>(
  (ref) => SnackbarState(),
);

class SnackbarState {
  String? message;
  bool isError;
  SnackbarState({this.message, this.isError = false});
}
