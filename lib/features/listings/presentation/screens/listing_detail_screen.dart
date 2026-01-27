import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/food_listing_model.dart';
import '../../../../core/models/food_request_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../providers/listings_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import 'edit_listing_screen.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _navigateToEdit(BuildContext context, FoodListing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditListingScreen(listingId: listing.id),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, FoodListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Delete Listing',
          style: AppTypography.h3(color: AppColors.pureWhite),
        ),
        content: Text(
          'Are you sure you want to delete "${listing.title}"? This action cannot be undone.',
          style: AppTypography.body(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.body(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTypography.button(color: AppColors.pureWhite),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final controller = ref.read(listingsControllerProvider.notifier);
      final success = await controller.deleteListing(listing.id);

      if (success && mounted) {
        AppToast.success(context, 'Listing deleted successfully');
        Navigator.pop(context);
      } else if (mounted) {
        final error = ref.read(listingsControllerProvider).error;
        AppToast.error(
          context,
          error ?? 'Failed to delete listing. Please try again.',
        );
      }
    }
  }

  void _showRequestDialogWidget(BuildContext context, FoodListing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Send Request',
          style: AppTypography.h3(color: AppColors.pureWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request ${listing.title}',
              style: AppTypography.body(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: AppTypography.body(color: AppColors.pureWhite),
              decoration: InputDecoration(
                hintText: 'Optional message to donor...',
                hintStyle: AppTypography.body(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.darkGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _messageController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: AppTypography.body(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Send',
              style: AppTypography.button(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRequest() async {
    final listingAsync = ref.read(availableListingsProvider);

    // Get listing from stream
    final listing = await listingAsync.when(
      data: (listings) => listings.firstWhere(
        (l) => l.id == widget.listingId,
        orElse: () => throw Exception('Listing not found'),
      ),
      loading: () => throw Exception('Loading...'),
      error: (_, __) => throw Exception('Error loading listing'),
    );

    final controller = ref.read(listingsControllerProvider.notifier);
    final success = await controller.createRequest(
      listingId: widget.listingId,
      donorId: listing.donorId,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    );

    if (success && mounted) {
      AppToast.success(context, 'Request sent successfully!');
      _messageController.clear();
    } else if (mounted) {
      final error = ref.read(listingsControllerProvider).error;
      AppToast.error(
        context,
        error ?? 'Failed to send request. Please try again.',
      );
    }
  }

  Future<void> _acceptRequest(String requestId, String listingId) async {
    final controller = ref.read(listingsControllerProvider.notifier);
    final success = await controller.acceptRequest(requestId, listingId);

    if (success && mounted) {
      AppToast.success(context, 'Request accepted!');
    } else if (mounted) {
      final error = ref.read(listingsControllerProvider).error;
      AppToast.error(
        context,
        error ?? 'Failed to accept request. Please try again.',
      );
    }
  }

  Future<void> _rejectRequest(String requestId, String listingId) async {
    final controller = ref.read(listingsControllerProvider.notifier);
    final success = await controller.rejectRequest(requestId, listingId);

    if (success && mounted) {
      AppToast.success(context, 'Request rejected');
    } else if (mounted) {
      final error = ref.read(listingsControllerProvider).error;
      AppToast.error(
        context,
        error ?? 'Failed to reject request. Please try again.',
      );
    }
  }

  Future<void> _refreshListing() async {
    // Invalidate providers to force refresh
    ref.invalidate(availableListingsProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      // Get listing to find donorId
      final listingAsync = ref.read(availableListingsProvider);
      listingAsync.whenData((listings) {
        final listing = listings.firstWhere(
          (l) => l.id == widget.listingId,
          orElse: () => throw Exception('Listing not found'),
        );
        if (currentUser.uid == listing.donorId) {
          ref.invalidate(listingRequestsProvider({
            'listingId': widget.listingId,
            'donorId': listing.donorId,
          }));
        }
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final listingAsync = ref.watch(availableListingsProvider);

    return listingAsync.when(
      data: (listings) {
        final listing = listings.firstWhere(
          (l) => l.id == widget.listingId,
          orElse: () => throw Exception('Listing not found'),
        );

        final isDonor = currentUser?.uid == listing.donorId;
        print('👤 [ListingDetail] User check:');
        print('   - currentUser?.uid: ${currentUser?.uid}');
        print('   - listing.donorId: ${listing.donorId}');
        print('   - isDonor: $isDonor');
        
        final requestsAsync = isDonor && currentUser != null
            ? ref.watch(listingRequestsProvider({
                'listingId': widget.listingId,
                'donorId': listing.donorId,
              }))
            : null;
        
        print('   - requestsAsync: ${requestsAsync != null ? "created" : "null"}');

        // Check if receiver has already requested
        final hasRequestedAsync = !isDonor && currentUser != null && listing.isAvailable
            ? ref.watch(hasUserRequestedProvider({
                'listingId': widget.listingId,
                'receiverId': currentUser.uid,
              }))
            : null;

        return Scaffold(
          backgroundColor: AppColors.black,
          body: RefreshIndicator(
            onRefresh: _refreshListing,
            color: AppColors.accentGreen,
            backgroundColor: AppColors.cardDark,
            child: CustomScrollView(
            slivers: [
              // App Bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.cardDark,
                flexibleSpace: FlexibleSpaceBar(
                  background: listing.imageUrls.isNotEmpty
                      ? Image.network(
                          listing.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.cardDark,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.grey,
                                  size: 64,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.cardDark,
                          child: const Center(
                            child: Icon(
                              Icons.fastfood,
                              color: AppColors.grey,
                              size: 64,
                            ),
                          ),
                        ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              style: AppTypography.h1(
                                color: AppColors.pureWhite,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          _buildStatusBadge(listing.status),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Food Type and Location
                      Row(
                        children: [
                          Icon(
                            _getFoodTypeIcon(listing.foodType),
                            color: AppColors.accentGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getFoodTypeLabel(listing.foodType),
                            style: AppTypography.bodySmall(
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.location_on,
                            color: AppColors.accentGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${listing.area}, ${listing.city}',
                            style: AppTypography.bodySmall(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'Description',
                        style: AppTypography.h3(color: AppColors.pureWhite),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description,
                        style: AppTypography.body(color: AppColors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Details Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              icon: Icons.people,
                              label: 'Servings',
                              value: '${listing.servings}',
                            ),
                            const Divider(color: AppColors.lightGrey),
                            _buildDetailRow(
                              icon: Icons.access_time,
                              label: 'Expires',
                              value: _formatExpiryDate(listing.expiryDate),
                              isUrgent: listing.isUrgent,
                            ),
                            if (listing.address != null) ...[
                              const Divider(color: AppColors.lightGrey),
                              _buildDetailRow(
                                icon: Icons.location_on,
                                label: 'Address',
                                value: listing.address!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Image Gallery
                      if (listing.imageUrls.length > 1) ...[
                        Text(
                          'More Images',
                          style: AppTypography.h3(color: AppColors.pureWhite),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listing.imageUrls.length - 1,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    listing.imageUrls[index + 1],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Donor View: Show Requests
                      if (isDonor) ...[
                        Row(
                          children: [
                            Text(
                              'Requests',
                              style: AppTypography.h3(color: AppColors.pureWhite),
                            ),
                            const Spacer(),
                            if (requestsAsync != null)
                              requestsAsync.when(
                                data: (requests) => Text(
                                  '${requests.length} pending',
                                  style: AppTypography.bodySmall(
                                    color: AppColors.grey,
                                  ),
                                ),
                                loading: () => const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                                error: (_, __) => const SizedBox(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        requestsAsync?.when(
                          data: (requests) {
                            if (requests.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.lightGrey),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: AppColors.grey,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No requests yet',
                                        style: AppTypography.body(
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Share this listing to get requests',
                                        style: AppTypography.bodySmall(
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: requests.map((request) {
                                return _buildRequestCard(request, listing.id);
                              }).toList(),
                            );
                          },
                          loading: () {
                            print('⏳ [ListingDetail] Requests loading...');
                            return Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    color: AppColors.accentGreen,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading requests...',
                                    style: AppTypography.bodySmall(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          error: (error, stack) {
                            print('❌ [ListingDetail] Requests error: $error');
                            print('   - Stack: $stack');
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error loading requests',
                                    style: AppTypography.body(
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    error.toString(),
                                    style: AppTypography.bodySmall(
                                      color: AppColors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ) ?? const SizedBox(),
                      ],

                      // Donor View: Edit/Delete Buttons
                      if (isDonor) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _navigateToEdit(context, listing),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accentGreen,
                                  side: const BorderSide(color: AppColors.accentGreen),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(Icons.edit, size: 20),
                                label: Text(
                                  'Edit',
                                  style: AppTypography.button(
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showDeleteDialog(context, listing),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(Icons.delete_outline, size: 20),
                                label: Text(
                                  'Delete',
                                  style: AppTypography.button(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Receiver View: Request Button
                      if (!isDonor && listing.isAvailable) ...[
                        hasRequestedAsync?.when(
                          data: (hasRequested) {
                            if (hasRequested) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.accentGreen),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.accentGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Request Sent',
                                      style: AppTypography.button(
                                        color: AppColors.accentGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _showRequestDialogWidget(context, listing),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentGreen,
                                  foregroundColor: AppColors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Send Request',
                                      style: AppTypography.button(
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 56,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentGreen,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          error: (_, __) => SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _showRequestDialogWidget(context, listing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                foregroundColor: AppColors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Send Request',
                                    style: AppTypography.button(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) ?? const SizedBox(),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.black,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Text(
            'Error loading listing: $error',
            style: AppTypography.body(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ListingStatus status) {
    Color color;
    String label;

    switch (status) {
      case ListingStatus.available:
        color = AppColors.accentGreen;
        label = 'Available';
        break;
      case ListingStatus.reserved:
        color = Colors.orange;
        label = 'Reserved';
        break;
      case ListingStatus.completed:
        color = AppColors.grey;
        label = 'Completed';
        break;
      case ListingStatus.expired:
        color = Colors.red;
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTypography.caption(color: color),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isUrgent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption(color: AppColors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.body(
                    color: isUrgent ? Colors.orange : AppColors.pureWhite,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(FoodRequest request, String listingId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Request from User',
                  style: AppTypography.body(color: AppColors.pureWhite),
                ),
              ),
              Text(
                DateFormat('MMM d, h:mm a').format(request.createdAt),
                style: AppTypography.caption(color: AppColors.grey),
              ),
            ],
          ),
          if (request.message != null) ...[
            const SizedBox(height: 8),
            Text(
              request.message!,
              style: AppTypography.bodySmall(color: AppColors.grey),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectRequest(request.id, listingId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(request.id, listingId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatExpiryDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inHours < 6) {
      return 'Expires in ${difference.inHours}h ${difference.inMinutes % 60}m (Urgent!)';
    } else if (difference.inDays < 1) {
      return 'Expires in ${difference.inHours}h';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(date);
    }
  }

  IconData _getFoodTypeIcon(FoodType type) {
    switch (type) {
      case FoodType.cooked:
        return Icons.lunch_dining;
      case FoodType.packaged:
        return Icons.inventory_2;
      case FoodType.bakery:
        return Icons.cake;
      case FoodType.beverages:
        return Icons.local_drink;
    }
  }

  String _getFoodTypeLabel(FoodType type) {
    switch (type) {
      case FoodType.cooked:
        return 'Cooked';
      case FoodType.packaged:
        return 'Packaged';
      case FoodType.bakery:
        return 'Bakery';
      case FoodType.beverages:
        return 'Beverages';
    }
  }
}

