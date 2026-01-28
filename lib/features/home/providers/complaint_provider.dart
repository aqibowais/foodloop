import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/utils/constants.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Complaint controller state
class ComplaintState {
  final bool isLoading;
  final String? error;

  const ComplaintState({
    this.isLoading = false,
    this.error,
  });

  ComplaintState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ComplaintState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Complaint controller
class ComplaintController extends StateNotifier<ComplaintState> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ComplaintController(this._ref) : super(const ComplaintState());

  /// Submit a complaint
  Future<bool> submitComplaint({
    required String listingId,
    required ComplaintCategory category,
    required String description,
    String? againstUserId,
  }) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = state.copyWith(error: 'User not logged in');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final complaint = Complaint(
        id: _firestore.collection(AppConstants.complaintsCollection).doc().id,
        listingId: listingId,
        complainantId: currentUser.uid,
        againstUserId: againstUserId,
        category: category,
        description: description,
        status: ComplaintStatus.submitted,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(complaint.id)
          .set(complaint.toJson());

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Complaint controller provider
final complaintControllerProvider =
    StateNotifierProvider<ComplaintController, ComplaintState>((ref) {
  return ComplaintController(ref);
});

