import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import '../config/cloudinary_config.dart';

/// Simple Cloudinary storage service for FoodLoop.
/// Uses Cloudinary for image storage (not Firebase Storage).
class StorageService {
  StorageService({String? cloudName, String? uploadPreset})
    : _cloudName = cloudName ?? CloudinaryConfig.cloudName,
      _uploadPreset = uploadPreset ?? CloudinaryConfig.uploadPreset,
      _cloudinary = CloudinaryPublic(
        cloudName ?? CloudinaryConfig.cloudName,
        uploadPreset ?? CloudinaryConfig.uploadPreset,
        cache: false,
      );

  final CloudinaryPublic _cloudinary;
  final String _cloudName;
  final String _uploadPreset;

  /// Factory constructor using centralized config
  factory StorageService.fromConfig() {
    return StorageService();
  }

  /// Upload any image file and return its secure URL.
  /// Handles image compression and proper Cloudinary upload.
  Future<String?> uploadImage(
    File imageFile, {
    String? folder,
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        debugPrint('ERROR: [StorageService] Image file does not exist');
        return null;
      }

      // Check file size (max 10MB for Cloudinary free tier)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        debugPrint(
          'ERROR: [StorageService] Image file too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
        );
        return null;
      }

      debugPrint(
        'INFO: [StorageService] Uploading image: ${imageFile.path}, size: ${(fileSize / 1024).toStringAsFixed(2)}KB',
      );
      debugPrint(
        'INFO: [StorageService] Using Cloudinary: cloudName=$_cloudName, uploadPreset=$_uploadPreset',
      );

      // Upload to Cloudinary with proper parameters
      // Note: Image compression should be done before upload (via image_picker)
      // Cloudinary transformations can be applied when displaying images
      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        folder: folder ?? CloudinaryConfig.baseFolder,
        resourceType: CloudinaryResourceType.Image,
      );

      final response = await _cloudinary.uploadFile(cloudinaryFile);

      debugPrint(
        'SUCCESS: [StorageService] Image uploaded: ${response.secureUrl}',
      );
      return response.secureUrl;
    } catch (e, stackTrace) {
      // Enhanced error logging
      debugPrint('ERROR: [StorageService] Image upload failed: $e');
      debugPrint('ERROR: [StorageService] Stack trace: $stackTrace');

      // Provide more specific error messages
      if (e.toString().contains('400')) {
        debugPrint(
          'ERROR: [StorageService] Bad request (400). Possible causes:',
        );
        debugPrint(
          '  - Upload preset "$_uploadPreset" does not exist in Cloudinary',
        );
        debugPrint(
          '  - Upload preset is set to "Signed" instead of "Unsigned"',
        );
        debugPrint('  - Cloud name "$_cloudName" is incorrect');
        debugPrint(
          '  - Check CLOUDINARY_SETUP.md for configuration instructions',
        );
      } else if (e.toString().contains('401')) {
        debugPrint(
          'ERROR: [StorageService] Unauthorized (401). Check Cloudinary credentials.',
        );
      } else if (e.toString().contains('413')) {
        debugPrint(
          'ERROR: [StorageService] File too large (413). Compress image before upload.',
        );
      }

      return null;
    }
  }
}
