import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Simple Cloudinary storage service for FoodLoop.
/// You can wire this to your own Cloudinary account later.
class StorageService {
  StorageService({
    required String cloudName,
    required String uploadPreset,
  }) : _cloudinary = CloudinaryPublic(
          cloudName,
          uploadPreset,
          cache: false,
        );

  final CloudinaryPublic _cloudinary;

  /// Upload any image file and return its secure URL.
  Future<String?> uploadImage(File imageFile, {String folder = 'images'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      // For MVP we just log and return null; caller can handle gracefully.
      // ignore: avoid_print
      print('ERROR: [StorageService] Image upload failed: $e');
      return null;
    }
  }
}
