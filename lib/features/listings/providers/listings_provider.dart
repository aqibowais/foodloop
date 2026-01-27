import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/food_listing_model.dart';
import '../../../core/models/food_request_model.dart';
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
final availableListingsProvider = StreamProvider<List<FoodListing>>((ref) {
  final service = ref.watch(listingsServiceProvider);
  return service.getAvailableListings();
});

/// Donor listings provider
final donorListingsProvider = StreamProvider.family<List<FoodListing>, String>((ref, donorId) {
  final service = ref.watch(listingsServiceProvider);
  return service.getDonorListings(donorId);
});

/// Listing requests provider
final listingRequestsProvider = StreamProvider.family<List<FoodRequest>, Map<String, String?>>((ref, params) {
  print('🔄 [ListingsProvider] listingRequestsProvider called');
  print('   - params: $params');
  
  final service = ref.watch(listingsServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  print('   - currentUser: ${currentUser?.uid ?? "null"}');
  
  if (currentUser == null) {
    print('⚠️ [ListingsProvider] Current user is null!');
  }
  
  try {
    final stream = service.getListingRequests(
      params['listingId']!,
      donorId: params['donorId'],
      currentUserId: currentUser?.uid,
    );
    
    print('✅ [ListingsProvider] Stream created successfully');
    return stream;
  } catch (e, stackTrace) {
    print('❌ [ListingsProvider] Error creating stream: $e');
    print('   - Stack trace: $stackTrace');
    rethrow;
  }
});

/// Receiver requests provider
final receiverRequestsProvider = StreamProvider.family<List<FoodRequest>, String>((ref, receiverId) {
  final service = ref.watch(listingsServiceProvider);
  return service.getReceiverRequests(receiverId);
});

/// Listing request count provider (for donors)
final listingRequestCountProvider = StreamProvider.family<int, Map<String, String>>((ref, params) {
  final service = ref.watch(listingsServiceProvider);
  return service.getListingRequestCount(
    params['listingId']!,
    params['donorId']!,
  );
});

/// Check if user has requested a listing
final hasUserRequestedProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final service = ref.watch(listingsServiceProvider);
  return service.hasUserRequestedListing(
    params['listingId']!,
    params['receiverId']!,
  );
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
        id: _firestore
            .collection('listings')
            .doc()
            .id, // Generate ID
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
        id: _firestore
            .collection('requests')
            .doc()
            .id,
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

      // Get the request to find receiver ID
      final requests = await _listingsService
          .getListingRequests(
            listingId,
            donorId: listing.donorId,
            currentUserId: currentUser.uid,
          )
          .first;
      final request = requests.firstWhere((r) => r.id == requestId);

      // Update request status
      await _listingsService.updateRequestStatus(
        requestId,
        RequestStatus.accepted,
      );

      // Update listing status to reserved
      await _listingsService.updateListingStatus(
        listingId,
        ListingStatus.reserved,
        reservedForUserId: request.receiverId,
      );

      // Reject all other pending requests for this listing
      for (final otherRequest in requests) {
        if (otherRequest.id != requestId && otherRequest.isPending) {
          await _listingsService.updateRequestStatus(
            otherRequest.id,
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
        state = state.copyWith(error: 'Only the listing owner can reject requests');
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

