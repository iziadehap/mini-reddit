// lib/core/models/success.dart

/// Standard response model for successful operations.
class SuccessModel {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  SuccessModel({required this.success, this.message, this.data});

  SuccessModel copyWith({
    bool? success,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return SuccessModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  factory SuccessModel.fromJson(Map<String, dynamic> json) {
    return SuccessModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data,
      };
}
