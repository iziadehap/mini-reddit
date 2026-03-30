// lib/core/models/post_image.dart

class PostImage {
  final String id;
  final String imageUrl;

  PostImage({required this.id, required this.imageUrl});

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id']?.toString() ?? '',
      imageUrl: json['url']?.toString() ?? json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
      };

  PostImage copyWith({String? id, String? imageUrl}) {
    return PostImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
