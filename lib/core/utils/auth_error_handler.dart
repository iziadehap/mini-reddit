import 'package:mini_reddit_v2/core/models/failure_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandler {
  static Failure handle(Object error, [String? defaultMessage]) {
    if (error is AuthException) {
      return _handleAuthException(error);
    }

    // Handle other types of errors if necessary (e.g., PostgrestException)
    if (error is PostgrestException) {
      return ServerFailure(message: error.message, code: error.code);
    }

    return ServerFailure(
      message: defaultMessage ?? error.toString(),
      code: error.toString(),
    );
  }

  static Failure _handleAuthException(AuthException e) {
    final message = _mapAuthMessage(e);
    return AuthFailure(
      message: message,
      statusCode: e.statusCode,
      code: e.message,
    );
  }

  static String _mapAuthMessage(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('user already exists') ||
        msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (msg.contains('otp expired')) {
      return 'The verification code has expired. Please request a new one.';
    }
    if (msg.contains('invalid format') || msg.contains('validation failed')) {
      return 'Please check your input and try again.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    // Fallback to a cleaner version of the original message or a default
    if (e.message.length > 50) {
      return 'Authentication failed. Please try again.';
    }

    return e.message;
  }
}
