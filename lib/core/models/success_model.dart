class SuccessModel {
  final bool success;
  String? message;
  Map<String, dynamic>? data;

  SuccessModel({required this.success, this.message, this.data});

  // cupy with
  SuccessModel copyWith({bool? success, String? message, Map<String, dynamic>? data}) {
    return SuccessModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
