import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/utils/constants.dart';

/// Service for admin operations
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all complaints
  Stream<List<Complaint>> getAllComplaints() {
    return _firestore
        .collection(AppConstants.complaintsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Complaint.fromJson({'id': doc.id, ...data});
      }).toList();
    });
  }

  /// Update complaint status
  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus status, {
    String? adminNotes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
      };

      if (status == ComplaintStatus.resolved) {
        updateData['resolvedAt'] = DateTime.now().toIso8601String();
      }

      if (adminNotes != null && adminNotes.isNotEmpty) {
        updateData['adminNotes'] = adminNotes;
      }

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(complaintId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error updating complaint status: $e');
    }
  }

  /// Get analytics data
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      // Get counts from all collections
      final listingsSnapshot =
          await _firestore.collection(AppConstants.listingsCollection).get();
      final requestsSnapshot =
          await _firestore.collection(AppConstants.requestsCollection).get();
      final usersSnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();
      final complaintsSnapshot =
          await _firestore.collection(AppConstants.complaintsCollection).get();

      // Count by status
      int availableListings = 0;
      int reservedListings = 0;
      int completedListings = 0;
      int expiredListings = 0;

      int pendingRequests = 0;
      int acceptedRequests = 0;
      int rejectedRequests = 0;

      int submittedComplaints = 0;
      int underReviewComplaints = 0;
      int resolvedComplaints = 0;

      for (var doc in listingsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'available';
        switch (status) {
          case 'available':
            availableListings++;
            break;
          case 'reserved':
            reservedListings++;
            break;
          case 'completed':
            completedListings++;
            break;
          case 'expired':
            expiredListings++;
            break;
        }
      }

      for (var doc in requestsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'pending';
        switch (status) {
          case 'pending':
            pendingRequests++;
            break;
          case 'accepted':
            acceptedRequests++;
            break;
          case 'rejected':
            rejectedRequests++;
            break;
        }
      }

      for (var doc in complaintsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'submitted';
        switch (status) {
          case 'submitted':
            submittedComplaints++;
            break;
          case 'underReview':
            underReviewComplaints++;
            break;
          case 'resolved':
            resolvedComplaints++;
            break;
        }
      }

      return {
        'totalListings': listingsSnapshot.docs.length,
        'availableListings': availableListings,
        'reservedListings': reservedListings,
        'completedListings': completedListings,
        'expiredListings': expiredListings,
        'totalRequests': requestsSnapshot.docs.length,
        'pendingRequests': pendingRequests,
        'acceptedRequests': acceptedRequests,
        'rejectedRequests': rejectedRequests,
        'totalUsers': usersSnapshot.docs.length,
        'totalComplaints': complaintsSnapshot.docs.length,
        'submittedComplaints': submittedComplaints,
        'underReviewComplaints': underReviewComplaints,
        'resolvedComplaints': resolvedComplaints,
      };
    } catch (e) {
      throw Exception('Error getting analytics: $e');
    }
  }
}

