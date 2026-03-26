import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadImage({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage
          .from(bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Return the public URL
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}
