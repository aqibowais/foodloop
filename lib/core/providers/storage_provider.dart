import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Centralized StorageService provider using CloudinaryConfig
/// This ensures all parts of the app use the same Cloudinary configuration
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.fromConfig();
});

