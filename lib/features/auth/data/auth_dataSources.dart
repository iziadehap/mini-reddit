import 'dart:io';
import 'package:mini_reddit_v2/core/services/storage_service.dart';
import 'package:mini_reddit_v2/core/utils/supabase_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final authDataSourceProvider = Provider<AuthDataSource>((ref) {
//   final client = ref.watch(supabaseClientProvider);
//   return AuthDataSource(client);
// });

class AuthDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadProfileImage(File image) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User is not authenticated');
    }

    final fileExtension = image.path.split('.').last;
    final path = '${user.id}/profile.$fileExtension';

    return StorageService().uploadImage(
      file: image,
      bucket: SupabaseText.userProfileBuckets,
      path: path,
    );
  }

  Future<void> resendOtp(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  Future<void> updateProfile({
    required String fullName,
    required String bio,
    required String username,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User is not authenticated');
    }

    await _supabase.from('profiles').upsert({
      'id': user.id,
      'username': username.trim(),
      'full_name': fullName.trim(),
      'bio': bio.trim(),
      'avatar_url': avatarUrl,
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
