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
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  /// Upload profile image to Cloudinary and return URL
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    if (_storageService == null) {
      // If no storage service configured, return null
      // In production, you'd want to configure Cloudinary properly
      return null;
    }

    try {
      final imageUrl = await _storageService.uploadImage(
        imageFile,
        folder: 'profile_images',
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

