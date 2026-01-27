import 'dart:io';
import '../../../core/services/storage_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_model.dart';

/// Service for profile-related operations
class ProfileService {
  final FirestoreService _firestoreService;
  final StorageService? _storageService;

  ProfileService({
    required FirestoreService firestoreService,
    StorageService? storageService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService;

  /// Upload profile image to Cloudinary and return URL
  /// Automatically compresses and resizes images for optimal upload
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    if (_storageService == null) {
      throw Exception(
        'Storage service not configured. Please configure Cloudinary.',
      );
    }

    try {
      // Upload with compression and size limits for profile images
      // Using centralized folder structure from CloudinaryConfig
      final imageUrl = await _storageService!.uploadImage(
        imageFile,
        folder: 'foodloop/profile_images/$userId',
        maxWidth: 800, // Max width for profile images
        maxHeight: 800, // Max height for profile images
        quality: 85, // Good quality with compression
      );
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateProfile(UserModel user) async {
    await _firestoreService.createOrUpdateUser(user);
  }
}
