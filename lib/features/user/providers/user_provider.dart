import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

/// User data provider - loads user when authenticated
final userDataProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  var userModel = await firestoreService.getUser(user.uid);

  if (userModel == null) {
    // Create new user
    userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await firestoreService.createOrUpdateUser(userModel);
  } else {
    // Update with latest Firebase Auth data
    userModel = userModel.copyWith(
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
    await firestoreService.createOrUpdateUser(userModel);
  }

  return userModel;
});

/// User controller provider
final userControllerProvider = StateNotifierProvider<UserController, UserState>(
  (ref) {
    return UserController(ref);
  },
);

/// User state
class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// User controller
class UserController extends StateNotifier<UserState> {
  final Ref _ref;

  UserController(this._ref) : super(UserState()) {
    // Watch user data and update state
    _ref.listen(userDataProvider, (previous, next) {
      next.whenData((userModel) {
        state = state.copyWith(user: userModel);
      });
    });
  }

  FirestoreService get _firestoreService => _ref.read(firestoreServiceProvider);

  Future<void> updateProfile({String? displayName}) async {
    if (state.user == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final updatedUser = state.user!.copyWith(displayName: displayName);
      await _firestoreService.createOrUpdateUser(updatedUser);

      // Also update Firebase Auth display name if possible
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null && displayName != null) {
        await currentUser.updateDisplayName(displayName);
      }

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (state.user == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final updatedUser = state.user!.copyWith(photoUrl: imageUrl);
      await _firestoreService.createOrUpdateUser(updatedUser);

      // Also update Firebase Auth photo URL if possible
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        await currentUser.updatePhotoURL(imageUrl);
      }

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }
}
