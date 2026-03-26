// // نموذج تفاصيل المنشور
// class PostDetailsModel {
//   final String id;
//   final String content;
//   final String? linkUrl;
//   final String? postType;
//   final DateTime createdAt;
  
//   // معلومات الكاتب
//   final String authorId;
//   final String authorUsername;
//   final String? authorFullName;
//   final String? authorAvatarUrl;
  
//   // إحصائيات
//   final int score;
//   final int? userVote;
//   final int commentsCount;
  
//   // الصور والمجتمعات
//   final List<PostImage> images;
//   final List<Community> communities;
  
//   // التعليقات
//   final List<CommentModel> comments;

//   PostDetailsModel({
//     required this.id,
//     required this.content,
//     this.linkUrl,
//     this.postType,
//     required this.createdAt,
//     required this.authorId,
//     required this.authorUsername,
//     this.authorFullName,
//     this.authorAvatarUrl,
//     required this.score,
//     this.userVote,
//     required this.commentsCount,
//     required this.images,
//     required this.communities,
//     required this.comments,
//   });

//   factory PostDetailsModel.fromJson(Map<String, dynamic> json) {
//     // معالجة الصور
//     List<PostImage> imagesList = [];
//     if (json['images'] != null && json['images'] is List) {
//       imagesList = (json['images'] as List)
//           .map((imgJson) => PostImage.fromJson(imgJson as Map<String, dynamic>))
//           .toList();
//     }

//     // معالجة المجتمعات
//     List<Community> communitiesList = [];
//     if (json['communities'] != null && json['communities'] is List) {
//       communitiesList = (json['communities'] as List)
//           .map((cJson) => Community.fromJson(cJson as Map<String, dynamic>))
//           .toList();
//     }

//     // معالجة التعليقات
//     List<CommentModel> commentsList = [];
//     if (json['comments'] != null && json['comments'] is List) {
//       commentsList = (json['comments'] as List)
//           .map((cJson) => CommentModel.fromJson(cJson as Map<String, dynamic>))
//           .toList();
//     }

//     return PostDetailsModel(
//       id: json['id']?.toString() ?? '',
//       content: json['content']?.toString() ?? '',
//       linkUrl: json['link_url']?.toString(),
//       postType: json['post_type']?.toString(),
//       createdAt: DateTime.parse(json['created_at'].toString()).toLocal(),
//       authorId: json['author_id']?.toString() ?? '',
//       authorUsername: json['author_username']?.toString() ?? '',
//       authorFullName: json['author_full_name']?.toString(),
//       authorAvatarUrl: json['author_avatar_url']?.toString(),
//       score: json['score'] != null ? (json['score'] as num).toInt() : 0,
//       userVote: json['user_vote'] != null ? (json['user_vote'] as num).toInt() : null,
//       commentsCount: json['comments_count'] != null ? (json['comments_count'] as num).toInt() : 0,
//       images: imagesList,
//       communities: communitiesList,
//       comments: commentsList,
//     );
//   }
// }

// // نموذج الصورة
// class PostImage {
//   final String id;
//   final String url;

//   PostImage({
//     required this.id,
//     required this.url,
//   });

//   factory PostImage.fromJson(Map<String, dynamic> json) {
//     return PostImage(
//       id: json['id']?.toString() ?? '',
//       url: json['url']?.toString() ?? '',
//     );
//   }
// }

// // نموذج المجتمع
// class Community {
//   final String id;
//   final String name;
//   final String? imageUrl;

//   Community({
//     required this.id,
//     required this.name,
//     this.imageUrl,
//   });

//   factory Community.fromJson(Map<String, dynamic> json) {
//     return Community(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       imageUrl: json['image_url']?.toString(),
//     );
//   }
// }

// // نموذج التعليق
// class CommentModel {
//   final String id;
//   final String content;
//   final DateTime createdAt;
//   final String? parentId;
  
//   final String authorId;
//   final String authorUsername;
//   final String? authorFullName;
//   final String? authorAvatarUrl;
  
//   final int score;
//   final int? userVote;

//   CommentModel({
//     required this.id,
//     required this.content,
//     required this.createdAt,
//     this.parentId,
//     required this.authorId,
//     required this.authorUsername,
//     this.authorFullName,
//     this.authorAvatarUrl,
//     required this.score,
//     this.userVote,
//   });

//   factory CommentModel.fromJson(Map<String, dynamic> json) {
//     return CommentModel(
//       id: json['id']?.toString() ?? '',
//       content: json['content']?.toString() ?? '',
//       createdAt: DateTime.parse(json['created_at'].toString()).toLocal(),
//       parentId: json['parent_id']?.toString(),
//       authorId: json['author_id']?.toString() ?? '',
//       authorUsername: json['author_username']?.toString() ?? '',
//       authorFullName: json['author_full_name']?.toString(),
//       authorAvatarUrl: json['author_avatar_url']?.toString(),
//       score: json['score'] != null ? (json['score'] as num).toInt() : 0,
//       userVote: json['user_vote'] != null ? (json['user_vote'] as num).toInt() : null,
//     );
//   }
// }