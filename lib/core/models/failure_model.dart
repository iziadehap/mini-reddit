class Failure {
  final String message;
  final String? statusCode;
  final String? code;

  Failure(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure({required String message, String? statusCode, String? code})
    : super(message, statusCode: statusCode, code: code);
}

class AuthFailure extends Failure {
  AuthFailure({required String message, String? statusCode, String? code})
    : super(message, statusCode: statusCode, code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message, String? statusCode, String? code})
    : super(message, statusCode: statusCode, code: code);
}

class CacheFailure extends Failure {
  CacheFailure({required String message, String? statusCode, String? code})
    : super(message, statusCode: statusCode, code: code);
}
