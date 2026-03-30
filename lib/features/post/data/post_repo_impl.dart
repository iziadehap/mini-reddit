import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/domain/post_repo.dart';

class PostRepoImpl implements PostRepo {
  final PostDataSource _dataSource;

  PostRepoImpl(this._dataSource);

  @override
  Future<Either<Failure, SuccessModel>> savePost(String postId) async {
    try {
      final res = await _dataSource.savePost(postId);
      return Right(res);
    } catch (e) {
      debugPrint('error in save post: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> unsavePost(String postId) async {
    try {
      final res = await _dataSource.unsavePost(postId);
      return Right(res);
    } catch (e) {
      debugPrint('error in unsave post: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FeedPostModel>> createPost({
    required String communityId,
    required String title,
    required String content,
    String postType = 'text',
    String? linkUrl,
    String? flairId,
    List<String>? imageUrls,
  }) async {
    try {
      final res = await _dataSource.createPost(
        communityId: communityId,
        title: title,
        content: content,
        postType: postType,
        linkUrl: linkUrl,
        flairId: flairId,
        imageUrls: imageUrls,
      );
      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadPostImage(
    List<File> imageFiles,
  ) async {
    try {
      final imageUrl = await _dataSource.uploadPostImage(imageFiles);
      return Right(imageUrl);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> addComment({
    required String postId,
    required String content,
    required String userId,
    String? parentId,
  }) async {
    try {
      await _dataSource.addComment(
        parentId: parentId,
        postId: postId,
        content: content,
        userId: userId,
      );

      return Right(SuccessModel(success: true));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostDetailsModel>> getPostDetails({
    required String postId,
    required String userId,
  }) async {
    try {
      final data = await _dataSource.getPostDetails(
        postId: postId,
        userId: userId,
      );
      print('post details data from repo: $data');
      return Right(data);
    } catch (e) {
      print('error in get post details: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> voteComment({
    required String userId,
    required String commentId,
    required int value,
  }) async {
    try {
      final res = await _dataSource.voteComment(
        userId: userId,
        commentId: commentId,
        value: value,
      );
      print('vote comment response: $res');
      if (res['success'] == false) {
        print('its return failure');
        return Left(Failure(res['message']));
      }
      return Right(SuccessModel(success: true, data: res));
    } catch (e) {
      print('error in vote comment: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> votePost({
    required String userId,
    required String postId,
    required int value,
  }) async {
    try {
      final res = await _dataSource.votePost(
        userId: userId,
        postId: postId,
        value: value,
      );
      print('vote post response: $res');
      if (res['success'] == false) {
        print('its return failure');
        return Left(Failure(res['message']));
      }
      return Right(SuccessModel(success: true, data: res));
    } catch (e) {
      print('error in vote post: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuccessModel>> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final res = await _dataSource.deleteComment(
        commentId: commentId,
        userId: userId,
      );
      print('delete comment response: $res');
      if (res['success'] == false) {
        print('its return failure');
        return Left(Failure(res['message']));
      }
      return Right(SuccessModel(success: true));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
