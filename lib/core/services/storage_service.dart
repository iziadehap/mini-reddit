import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadImage({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      debugPrint('🔍 StorageService.uploadImage called');
      debugPrint('🔍 - Bucket: $bucket');
      debugPrint('🔍 - Path: $path');
      debugPrint('🔍 - File: ${file.path}');

      await _supabase.storage
          .from(bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      debugPrint('🔍 File uploaded successfully');

      // Return the public URL
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(path);

      debugPrint('🔍 Public URL generated: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Failed to upload image: ${e.toString()}');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}
