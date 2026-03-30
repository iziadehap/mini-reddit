// lib/core/models/flair.dart

class FlairModel {
  final String id;
  final String name;
  final String? color;

  FlairModel({
    required this.id,
    required this.name,
    this.color,
  });

  factory FlairModel.fromJson(Map<String, dynamic> json) {
    return FlairModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
      };

  FlairModel copyWith({String? id, String? name, String? color}) {
    return FlairModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
