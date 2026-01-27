import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/storage_provider.dart';
import '../services/profile_service.dart';
import '../../user/providers/user_provider.dart';

/// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // Use centralized StorageService from core providers
  final storageService = ref.watch(storageServiceProvider);
  return ProfileService(
    firestoreService: firestoreService,
    storageService: storageService,
  );
});

/// Profile controller provider
final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>(
      (ref) => ProfileController(ref),
    );

/// Profile state
class ProfileState {
  final bool isEditing;
  final bool isUploadingImage;
  final String? error;

  ProfileState({
    this.isEditing = false,
    this.isUploadingImage = false,
    this.error,
  });

  ProfileState copyWith({
    bool? isEditing,
    bool? isUploadingImage,
    String? error,
  }) {
    return ProfileState(
      isEditing: isEditing ?? this.isEditing,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      error: error ?? this.error,
    );
  }
}

/// Profile controller
class ProfileController extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileController(this._ref) : super(ProfileState());

  ProfileService get _profileService => _ref.read(profileServiceProvider);
  UserController get _userController =>
      _ref.read(userControllerProvider.notifier);

  /// Toggle edit mode
  void toggleEditMode() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  /// Cancel editing
  void cancelEditing() {
    state = state.copyWith(isEditing: false, error: null);
  }

  /// Update profile with new data
  Future<bool> updateProfile({
    String? displayName,
    String? city,
    String? area,
    String? organizationName,
  }) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) return false;

    try {
      state = state.copyWith(error: null);

      await _userController.updateProfile(
        displayName: displayName,
        city: city,
        area: area,
        organizationName: organizationName,
      );

      state = state.copyWith(isEditing: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Upload and set profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) return false;

    try {
      state = state.copyWith(isUploadingImage: true, error: null);

      final imageUrl = await _profileService.uploadProfileImage(
        imageFile,
        userState.user!.uid,
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload image. Please try again.');
      }

      await _userController.updateProfileImage(imageUrl);
      state = state.copyWith(isUploadingImage: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUploadingImage: false, error: e.toString());
      return false;
    }
  }
}
