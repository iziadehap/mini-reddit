import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';

class CommunityPhotoPicker {
  static Future<File?> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    File? selectedFile;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.tokens.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.tokens.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Choose Image Source', style: context.rTypo.titleMedium),
              const SizedBox(height: AppSpacing.xl),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: context.tokens.brandOrange,
                ),
                title: const Text('Take Photo'),
                onTap: () async {
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    selectedFile = File(photo.path);
                  }
                  if (context.mounted) {
                    Navigator.pop(bottomSheetContext);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo, color: context.tokens.brandOrange),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    selectedFile = File(image.path);
                  }
                  if (context.mounted) {
                    Navigator.pop(bottomSheetContext);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );

    return selectedFile;
  }
}
