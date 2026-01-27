import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/food_listing_model.dart';
import '../../../core/models/food_request_model.dart';
import '../../../core/utils/constants.dart';

/// Service for listing-related Firestore operations
class ListingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new food listing
  Future<String> createListing(FoodListing listing) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listing.id);
      await docRef.set(listing.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating listing: $e');
    }
  }

  /// Get a single listing by ID
  Future<FoodListing?> getListing(String listingId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listingId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return FoodListing.fromJson({'id': doc.id, ...data});
      }
      return null;
    } catch (e) {
      throw Exception('Error getting listing: $e');
    }
  }

  /// Get all available listings (no server-side filtering)
  /// All filtering (city, foodType, search) is done client-side
  Stream<List<FoodListing>> getAvailableListings() {
    try {
      return _firestore
          .collection(AppConstants.listingsCollection)
          .where('status', isEqualTo: ListingStatus.available.name)
          .orderBy('expiryDate', descending: false)
          .snapshots()
          .map((snapshot) {
            var listings = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return FoodListing.fromJson({'id': doc.id, ...data});
            }).toList();

            // Filter expired listings
            listings = listings.where((l) => !l.isExpired).toList();

            // Sort by urgency (expiring soon first)
            listings.sort((a, b) {
              if (a.isUrgent && !b.isUrgent) return -1;
              if (!a.isUrgent && b.isUrgent) return 1;
              return a.expiryDate.compareTo(b.expiryDate);
            });

            return listings;
          });
    } catch (e) {
      throw Exception('Error getting available listings: $e');
    }
  }

  /// Get listings created by a specific donor
  Stream<List<FoodListing>> getDonorListings(String donorId) {
    try {
      return _firestore
          .collection(AppConstants.listingsCollection)
          .where('donorId', isEqualTo: donorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return FoodListing.fromJson({'id': doc.id, ...data});
            }).toList();
          });
    } catch (e) {
      throw Exception('Error getting donor listings: $e');
    }
  }

  /// Update listing
  Future<void> updateListing(FoodListing listing) async {
    try {
      await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listing.id)
          .update(listing.toJson());
    } catch (e) {
      throw Exception('Error updating listing: $e');
    }
  }

  /// Delete listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listingId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting listing: $e');
    }
  }

  /// Update listing status
  Future<void> updateListingStatus(
    String listingId,
    ListingStatus status, {
    String? reservedForUserId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (reservedForUserId != null) {
        updateData['reservedForUserId'] = reservedForUserId;
      } else if (status != ListingStatus.reserved) {
        updateData['reservedForUserId'] = FieldValue.delete();
      }

      await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listingId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error updating listing status: $e');
    }
  }

  /// Create a food request
  Future<String> createRequest(FoodRequest request) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.requestsCollection)
          .doc(request.id);
      await docRef.set(request.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating request: $e');
    }
  }

  /// Get requests for a specific listing
  /// For donors: queries with donorId filter to match security rules
  /// For receivers: queries without donorId (they can only see their own requests)
  Stream<List<FoodRequest>> getListingRequests(
    String listingId, {
    String? donorId,
    String? currentUserId,
  }) {
    try {
      print('🔍 [ListingsService] getListingRequests called');
      print('   - listingId: $listingId');
      print('   - donorId: $donorId');
      print('   - currentUserId: $currentUserId');

      Query query = _firestore
          .collection(AppConstants.requestsCollection)
          .where('listingId', isEqualTo: listingId)
          .where('status', isEqualTo: RequestStatus.pending.name);

      // If donorId is provided and matches current user, filter by it
      // This ensures the security rule can verify the user is the donor
      if (donorId != null &&
          currentUserId != null &&
          donorId == currentUserId) {
        print('   - Filtering by donorId (user is the donor)');
        query = query.where('donorId', isEqualTo: donorId);
      } else if (currentUserId != null) {
        // If not the donor, only show requests where user is the receiver
        print('   - Filtering by receiverId (user is a receiver)');
        query = query.where('receiverId', isEqualTo: currentUserId);
      } else {
        print('   - No additional filters (currentUserId is null)');
      }

      print('   - Query created, listening to stream...');

      // Add timeout to prevent infinite loading
      return query
          .orderBy('createdAt', descending: false)
          .snapshots()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) {
              print('⏱️ [ListingsService] Stream timeout after 30 seconds');
              sink.addError(
                Exception('Request timeout: Stream took too long to respond'),
              );
            },
          )
          .map((snapshot) {
            print('📦 [ListingsService] Stream snapshot received');
            print('   - Docs count: ${snapshot.docs.length}');
            print('   - Metadata: ${snapshot.metadata}');

            try {
              final requests = snapshot.docs.map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  print('   - Parsing request doc: ${doc.id}');
                  print('   - Doc data keys: ${data.keys.toList()}');
                  return FoodRequest.fromJson({'id': doc.id, ...data});
                } catch (e, stackTrace) {
                  print('❌ [ListingsService] Error parsing doc ${doc.id}: $e');
                  print('   - Stack: $stackTrace');
                  throw Exception('Error parsing request ${doc.id}: $e');
                }
              }).toList();

              print(
                '✅ [ListingsService] Returning ${requests.length} requests',
              );
              return requests;
            } catch (e, stackTrace) {
              print('❌ [ListingsService] Error in map function: $e');
              print('   - Stack: $stackTrace');
              throw Exception('Error processing requests: $e');
            }
          })
          .handleError((error, stackTrace) {
            print('❌ [ListingsService] Stream error: $error');
            print('   - Error type: ${error.runtimeType}');
            print('   - Stack: $stackTrace');
            throw Exception('Stream error: $error');
          });
    } catch (e, stackTrace) {
      print('❌ [ListingsService] Exception in getListingRequests: $e');
      print('   - Stack trace: $stackTrace');
      throw Exception('Error getting listing requests: $e');
    }
  }

  /// Get requests made by a receiver
  Stream<List<FoodRequest>> getReceiverRequests(String receiverId) {
    try {
      return _firestore
          .collection(AppConstants.requestsCollection)
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return FoodRequest.fromJson({'id': doc.id, ...data});
            }).toList();
          });
    } catch (e) {
      throw Exception('Error getting receiver requests: $e');
    }
  }

  /// Get request count for a listing (for donors)
  Stream<int> getListingRequestCount(String listingId, String donorId) {
    try {
      return _firestore
          .collection(AppConstants.requestsCollection)
          .where('listingId', isEqualTo: listingId)
          .where('donorId', isEqualTo: donorId)
          .where('status', isEqualTo: RequestStatus.pending.name)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      throw Exception('Error getting listing request count: $e');
    }
  }

  /// Check if a receiver has requested a specific listing
  Future<bool> hasUserRequestedListing(
    String listingId,
    String receiverId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.requestsCollection)
          .where('listingId', isEqualTo: listingId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: RequestStatus.pending.name)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking user request: $e');
    }
  }

  /// Update request status (accept/reject)
  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.requestsCollection)
          .doc(requestId)
          .update({
            'status': status.name,
            'respondedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Error updating request status: $e');
    }
  }

  /// Mark listing as expired (can be called by scheduled function or manually)
  Future<void> markExpired(String listingId) async {
    await updateListingStatus(listingId, ListingStatus.expired);
  }
}
