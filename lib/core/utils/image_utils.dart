import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndCompressImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(
      dir.absolute.path,
      'temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 70, // Adjust quality as needed
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) return null;
    return File(compressedFile.path);
  }

  static Future<List<File>> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return [];

    final dir = await path_provider.getTemporaryDirectory();
    final List<File> compressedFiles = [];

    for (final image in images) {
      final targetPath = p.join(
        dir.absolute.path,
        'temp_${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(image)}.jpg',
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 70,
            format: CompressFormat.jpeg,
          );

      if (compressedFile != null) {
        compressedFiles.add(File(compressedFile.path));
      }
    }

    return compressedFiles;
  }
}
