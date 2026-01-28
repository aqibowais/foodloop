import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/food_listing_model.dart';
import '../../../core/models/food_request_model.dart';
import '../../../core/utils/constants.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../user/providers/user_provider.dart';
import '../services/listings_service.dart';

/// Listings service provider
final listingsServiceProvider = Provider<ListingsService>((ref) {
  return ListingsService();
});

/// Available listings provider (for discovery)
/// Fetches all available listings - filtering is done client-side
/// Waits for auth state to be ready before querying
final availableListingsProvider = StreamProvider<List<FoodListing>>((ref) {
  // Wait for auth state to be ready
  final authState = ref.watch(authStateProvider);

  // If auth is still loading, return empty stream
  if (authState.isLoading) {
    print('⏳ [ListingsProvider] Auth state loading, waiting...');
    return Stream.value(<FoodListing>[]);
  }

  // If auth error but user might still be authenticated, try anyway
  // Only block if we're sure there's no authenticated user
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null && authState.hasValue && authState.value == null) {
    print('⚠️ [ListingsProvider] No authenticated user, returning empty list');
    return Stream.value(<FoodListing>[]);
  }

  print('✅ [ListingsProvider] Auth ready, fetching listings');
  final service = ref.watch(listingsServiceProvider);
  return service.getAvailableListings();
});

/// Donor listings provider
final donorListingsProvider = StreamProvider.family<List<FoodListing>, String>((
  ref,
  donorId,
) {
  final service = ref.watch(listingsServiceProvider);
  return service.getDonorListings(donorId);
});

/// Single listing provider (fetches by ID regardless of status)
/// This is used for listing detail screen to show listings even when they're reserved/completed
final listingByIdProvider = FutureProvider.family<FoodListing?, String>((
  ref,
  listingId,
) async {
  final service = ref.watch(listingsServiceProvider);
  return await service.getListing(listingId);
});

/// Listing requests provider key class for stable comparison
class ListingRequestsKey {
  final String listingId;
  final String? donorId;

  ListingRequestsKey({required this.listingId, this.donorId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingRequestsKey &&
          runtimeType == other.runtimeType &&
          listingId == other.listingId &&
          donorId == other.donorId;

  @override
  int get hashCode => listingId.hashCode ^ donorId.hashCode;

  @override
  String toString() =>
      'ListingRequestsKey(listingId: $listingId, donorId: $donorId)';
}

/// Listing requests provider
/// Waits for auth state to be ready before querying
/// Uses a stable key class to prevent recreation on rebuilds
final listingRequestsProvider =
    StreamProvider.family<List<FoodRequest>, ListingRequestsKey>((ref, key) {
      print('🔄 [ListingsProvider] listingRequestsProvider called');
      print('   - key: $key');

      // Wait for auth state to be ready
      final authState = ref.watch(authStateProvider);
      final currentUser = ref.watch(currentUserProvider);

      print('   - authState.isLoading: ${authState.isLoading}');
      print('   - currentUser: ${currentUser?.uid ?? "null"}');

      // If auth is still loading, return empty stream
      if (authState.isLoading) {
        print('⏳ [ListingsProvider] Auth state loading, waiting...');
        return Stream.value(<FoodRequest>[]);
      }

      // If no authenticated user, return empty stream
      if (currentUser == null) {
        print(
          '⚠️ [ListingsProvider] Current user is null, returning empty list',
        );
        return Stream.value(<FoodRequest>[]);
      }

      // Validate required parameters
      if (key.listingId.isEmpty) {
        print('❌ [ListingsProvider] listingId is empty');
        return Stream.value(<FoodRequest>[]);
      }

      try {
        final service = ref.watch(listingsServiceProvider);
        final stream = service.getListingRequests(
          key.listingId,
          donorId: key.donorId,
          currentUserId: currentUser.uid,
        );

        print('✅ [ListingsProvider] Stream created successfully');

        // Wrap the stream to add logging
        return stream.map((requests) {
          print(
            '📊 [ListingsProvider] Stream emitted ${requests.length} requests',
          );
          return requests;
        });
      } catch (e, stackTrace) {
        print('❌ [ListingsProvider] Error creating stream: $e');
        print('   - Stack trace: $stackTrace');
        // Return empty stream instead of throwing to prevent UI crashes
        return Stream.value(<FoodRequest>[]);
      }
    });

/// Receiver requests provider
final receiverRequestsProvider =
    StreamProvider.family<List<FoodRequest>, String>((ref, receiverId) {
      final service = ref.watch(listingsServiceProvider);
      return service.getReceiverRequests(receiverId);
    });

/// Listing request count key for stable comparison
class ListingRequestCountKey {
  final String listingId;
  final String donorId;

  ListingRequestCountKey({required this.listingId, required this.donorId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingRequestCountKey &&
          runtimeType == other.runtimeType &&
          listingId == other.listingId &&
          donorId == other.donorId;

  @override
  int get hashCode => listingId.hashCode ^ donorId.hashCode;
}

/// Listing request count provider (for donors)
/// Waits for auth state to be ready before querying
final listingRequestCountProvider =
    StreamProvider.family<int, ListingRequestCountKey>((ref, key) {
      // Wait for auth state to be ready
      final authState = ref.watch(authStateProvider);
      final currentUser = ref.watch(currentUserProvider);

      // If auth is still loading or no user, return 0
      if (authState.isLoading || currentUser == null) {
        return Stream.value(0);
      }

      final service = ref.watch(listingsServiceProvider);
      return service.getListingRequestCount(key.listingId, key.donorId);
    });

/// Has user requested key for stable comparison
class HasUserRequestedKey {
  final String listingId;
  final String receiverId;

  HasUserRequestedKey({required this.listingId, required this.receiverId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HasUserRequestedKey &&
          runtimeType == other.runtimeType &&
          listingId == other.listingId &&
          receiverId == other.receiverId;

  @override
  int get hashCode => listingId.hashCode ^ receiverId.hashCode;
}

/// Check if user has requested a listing
/// Waits for auth state to be ready before querying
final hasUserRequestedProvider =
    FutureProvider.family<bool, HasUserRequestedKey>((ref, key) async {
      // Wait for auth state to be ready
      final authState = ref.watch(authStateProvider);
      final currentUser = ref.watch(currentUserProvider);

      // If auth is still loading or no user, return false
      if (authState.isLoading || currentUser == null) {
        return false;
      }

      final service = ref.watch(listingsServiceProvider);
      return service.hasUserRequestedListing(key.listingId, key.receiverId);
    });

/// Listings controller provider
final listingsControllerProvider =
    StateNotifierProvider<ListingsController, ListingsState>(
      (ref) => ListingsController(ref),
    );

/// Listings state
class ListingsState {
  final bool isCreating;
  final bool isUploadingImages;
  final String? error;

  ListingsState({
    this.isCreating = false,
    this.isUploadingImages = false,
    this.error,
  });

  ListingsState copyWith({
    bool? isCreating,
    bool? isUploadingImages,
    String? error,
  }) {
    return ListingsState(
      isCreating: isCreating ?? this.isCreating,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      error: error ?? this.error,
    );
  }
}

/// Listings controller
class ListingsController extends StateNotifier<ListingsState> {
  final Ref _ref;

  ListingsController(this._ref) : super(ListingsState());

  ListingsService get _listingsService => _ref.read(listingsServiceProvider);
  StorageService get _storageService => _ref.read(storageServiceProvider);
  final _firestore = FirebaseFirestore.instance;

  /// Create a new food listing
  Future<bool> createListing({
    required FoodType foodType,
    required String title,
    required String description,
    required int servings,
    required DateTime expiryDate,
    required String city,
    required String area,
    String? address,
    double? latitude,
    double? longitude,
    required List<File> imageFiles,
  }) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) {
      state = state.copyWith(error: 'User not logged in');
      return false;
    }

    try {
      state = state.copyWith(isCreating: true, error: null);

      // Upload images to Cloudinary
      state = state.copyWith(isUploadingImages: true);
      final imageUrls = <String>[];
      for (final imageFile in imageFiles) {
        final url = await _storageService.uploadImage(
          imageFile,
          folder: 'foodloop/listings/${userState.user!.uid}',
          maxWidth: 1200,
          maxHeight: 1200,
          quality: 85,
        );
        if (url != null) {
          imageUrls.add(url);
        }
      }
      state = state.copyWith(isUploadingImages: false);

      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images. Please try again.');
      }

      // Create listing
      final listing = FoodListing(
        id: _firestore.collection('listings').doc().id, // Generate ID
        donorId: userState.user!.uid,
        foodType: foodType,
        title: title,
        description: description,
        servings: servings,
        expiryDate: expiryDate,
        city: city,
        area: area,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
        status: ListingStatus.available,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _listingsService.createListing(listing);
      state = state.copyWith(isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        isUploadingImages: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Create a food request
  Future<bool> createRequest({
    required String listingId,
    required String donorId,
    String? message,
  }) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) {
      state = state.copyWith(error: 'User not logged in');
      return false;
    }

    // App-level validation: Prevent users from requesting their own listings
    if (userState.user!.uid == donorId) {
      state = state.copyWith(error: 'You cannot request your own listing');
      return false;
    }

    try {
      state = state.copyWith(error: null);

      final request = FoodRequest(
        id: _firestore.collection('requests').doc().id,
        listingId: listingId,
        donorId: donorId,
        receiverId: userState.user!.uid,
        status: RequestStatus.pending,
        message: message,
        createdAt: DateTime.now(),
      );

      await _listingsService.createRequest(request);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Accept a request (donor side)
  Future<bool> acceptRequest(String requestId, String listingId) async {
    try {
      state = state.copyWith(error: null);

      // Get listing to find donorId
      final listing = await _listingsService.getListing(listingId);
      if (listing == null) {
        throw Exception('Listing not found');
      }

      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the specific request directly from Firestore
      final request = await _listingsService.getRequest(requestId);
      if (request == null) {
        throw Exception('Request not found');
      }

      // Verify the request belongs to this listing
      if (request.listingId != listingId) {
        throw Exception('Request does not belong to this listing');
      }

      // Get all pending requests to reject them (only pending, not accepted)
      final firestore = FirebaseFirestore.instance;
      final allRequests = await firestore
          .collection(AppConstants.requestsCollection)
          .where('listingId', isEqualTo: listingId)
          .where('status', isEqualTo: RequestStatus.pending.name)
          .get();

      // Update request status
      await _listingsService.updateRequestStatus(
        requestId,
        RequestStatus.accepted,
      );

      // Update listing status to reserved (NOT completed - listing stays visible)
      await _listingsService.updateListingStatus(
        listingId,
        ListingStatus.reserved,
        reservedForUserId: request.receiverId,
      );

      // Reject all other pending requests for this listing
      for (final doc in allRequests.docs) {
        if (doc.id != requestId) {
          await _listingsService.updateRequestStatus(
            doc.id,
            RequestStatus.rejected,
          );
        }
      }

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reject a request (donor side)
  Future<bool> rejectRequest(String requestId, String listingId) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) {
      state = state.copyWith(error: 'User not logged in');
      return false;
    }

    try {
      state = state.copyWith(error: null);

      // Get listing to verify ownership
      final listing = await _listingsService.getListing(listingId);
      if (listing == null) {
        throw Exception('Listing not found');
      }

      // App-level validation: Only listing owner can reject requests
      if (listing.donorId != userState.user!.uid) {
        state = state.copyWith(
          error: 'Only the listing owner can reject requests',
        );
        return false;
      }

      await _listingsService.updateRequestStatus(
        requestId,
        RequestStatus.rejected,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Mark listing as completed
  Future<bool> markListingCompleted(String listingId) async {
    try {
      state = state.copyWith(error: null);
      await _listingsService.updateListingStatus(
        listingId,
        ListingStatus.completed,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update listing
  Future<bool> updateListing({
    required String listingId,
    required FoodType foodType,
    required String title,
    required String description,
    required int servings,
    required DateTime expiryDate,
    required String city,
    required String area,
    String? address,
    double? latitude,
    double? longitude,
    required List<String> existingImageUrls,
    List<File>? newImageFiles,
  }) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) {
      state = state.copyWith(error: 'User not logged in');
      return false;
    }

    try {
      state = state.copyWith(isCreating: true, error: null);

      // Get existing listing to check ownership
      final existingListing = await _listingsService.getListing(listingId);
      if (existingListing == null) {
        throw Exception('Listing not found');
      }

      // App-level validation: Only owner can update listing
      if (existingListing.donorId != userState.user!.uid) {
        state = state.copyWith(
          isCreating: false,
          error: 'You can only edit your own listings',
        );
        return false;
      }

      // Upload new images if provided
      final imageUrls = <String>[...existingImageUrls];
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        state = state.copyWith(isUploadingImages: true);
        for (final imageFile in newImageFiles) {
          final url = await _storageService.uploadImage(
            imageFile,
            folder: 'foodloop/listings/${userState.user!.uid}',
            maxWidth: 1200,
            maxHeight: 1200,
            quality: 85,
          );
          if (url != null) {
            imageUrls.add(url);
          }
        }
        state = state.copyWith(isUploadingImages: false);
      }

      if (imageUrls.isEmpty) {
        throw Exception('Listing must have at least one image');
      }

      // Update listing
      final updatedListing = existingListing.copyWith(
        foodType: foodType,
        title: title,
        description: description,
        servings: servings,
        expiryDate: expiryDate,
        city: city,
        area: area,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
        updatedAt: DateTime.now(),
      );

      await _listingsService.updateListing(updatedListing);
      state = state.copyWith(isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        isUploadingImages: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete listing
  Future<bool> deleteListing(String listingId) async {
    final userState = _ref.read(userControllerProvider);
    if (userState.user == null) {
      state = state.copyWith(error: 'User not logged in');
      return false;
    }

    try {
      state = state.copyWith(error: null);

      // Get existing listing to check ownership
      final existingListing = await _listingsService.getListing(listingId);
      if (existingListing == null) {
        throw Exception('Listing not found');
      }

      // App-level validation: Only owner can delete listing
      if (existingListing.donorId != userState.user!.uid) {
        state = state.copyWith(error: 'You can only delete your own listings');
        return false;
      }

      await _listingsService.deleteListing(listingId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
