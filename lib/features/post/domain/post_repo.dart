import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mini_reddit_v2/core/models/models.dart';

abstract class PostRepo {
  Future<Either<Failure, SuccessModel>> savePost(String postId);
  Future<Either<Failure, SuccessModel>> unsavePost(String postId);
  
  Future<Either<Failure, FeedPostModel>> createPost({
    required String communityId,
    required String title,
    required String content,
    String postType = 'text',
    String? linkUrl,
    String? flairId,
    List<String>? imageUrls,
  });
  Future<Either<Failure, List<String>>> uploadPostImage(List<File> imageFiles);

  Future<Either<Failure, SuccessModel>> voteComment({
    required String userId,
    required String commentId,
    required int value,
  });
  Future<Either<Failure, SuccessModel>> votePost({
    required String userId,
    required String postId,
    required int value,
  });
  Future<Either<Failure, PostDetailsModel>> getPostDetails({
    required String postId,
    required String userId,
  });
  Future<Either<Failure, SuccessModel>> addComment({
    required String postId,
    required String content,
    required String userId,
    String? parentId,
  });
  Future<Either<Failure, SuccessModel>> deleteComment({
    required String commentId,
    required String userId,
  });
}
