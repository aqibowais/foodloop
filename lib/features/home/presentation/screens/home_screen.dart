import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodloop/features/profile/presentation/screens/profile_screen.dart';

import '../../../../core/models/food_listing_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../listings/presentation/screens/create_listing_screen.dart';
import '../../../listings/presentation/screens/listing_detail_screen.dart';
import '../../../listings/providers/listings_provider.dart';
import '../../../user/providers/user_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final _searchController = TextEditingController();

  final List<_CategoryItem> _categories = const [
    _CategoryItem(icon: Icons.restaurant, label: 'All'),
    _CategoryItem(icon: Icons.lunch_dining, label: 'Cooked'),
    _CategoryItem(icon: Icons.inventory_2, label: 'Packaged'),
    _CategoryItem(icon: Icons.cake, label: 'Bakery'),
    _CategoryItem(icon: Icons.local_drink, label: 'Beverages'),
  ];

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Rebuild when search text changes
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  FoodType? _getSelectedFoodType() {
    if (_selectedCategoryIndex == 0) return null;
    switch (_selectedCategoryIndex) {
      case 1:
        return FoodType.cooked;
      case 2:
        return FoodType.packaged;
      case 3:
        return FoodType.bakery;
      case 4:
        return FoodType.beverages;
      default:
        return null;
    }
  }

  List<FoodListing> _applyLocalFilters(List<FoodListing> listings) {
    var filtered = listings;

    // Filter by food type
    final selectedFoodType = _getSelectedFoodType();
    if (selectedFoodType != null) {
      filtered = filtered.where((l) => l.foodType == selectedFoodType).toList();
    }

    // Filter by search query
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (l) =>
                l.title.toLowerCase().contains(queryLower) ||
                l.description.toLowerCase().contains(queryLower) ||
                l.city.toLowerCase().contains(queryLower) ||
                (l.area?.toLowerCase().contains(queryLower) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.user;

    // Get all available listings (no server-side filtering)
    final listingsAsync = ref.watch(availableListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top header with location and profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.accentGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user?.city != null && user?.area != null
                          ? '${user!.area}, ${user.city}'
                          : user?.city ?? 'Set your location',
                      style: AppTypography.body(
                        color: AppColors.pureWhite,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile icon button
                  GestureDetector(
                    onTap: _navigateToProfile,
                    child: user?.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              user!.photoUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderAvatar(40);
                              },
                            ),
                          )
                        : _buildPlaceholderAvatar(40),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextFormField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search food listings...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.32),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.red.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            // Category filters
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedCategoryIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentGreen
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentGreen
                                : AppColors.lightGrey,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categories[index].icon,
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.accentGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _categories[index].label,
                              style: AppTypography.body(
                                color: isSelected
                                    ? AppColors.black
                                    : AppColors.pureWhite,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Content area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Invalidate the provider to refresh
                  ref.invalidate(availableListingsProvider);
                  // Wait a bit for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: AppColors.accentGreen,
                backgroundColor: AppColors.cardDark,
                child: listingsAsync.when(
                  data: (allListings) {
                    // Apply local filters
                    final listings = _applyLocalFilters(allListings);

                    if (listings.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.food_bank_outlined,
                                  size: 64,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No listings found',
                                  style: AppTypography.body(
                                    color: AppColors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to share food!',
                                  style: AppTypography.bodySmall(
                                    color: AppColors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateListingScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentGreen,
                                    foregroundColor: AppColors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create Listing',
                                        style: AppTypography.button(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Available Listings section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available Listings',
                              style: AppTypography.h3(
                                color: AppColors.pureWhite,
                                fontSize: 20,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateListingScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.accentGreen,
                                size: 20,
                              ),
                              label: Text(
                                'Create',
                                style: AppTypography.body(
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Listing cards
                        ...listings.map((listing) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ListingDetailScreen(
                                      listingId: listing.id,
                                    ),
                                  ),
                                );
                              },
                              child: _buildListingCard(
                                listing: listing,
                                currentUserId: ref
                                    .read(currentUserProvider)
                                    ?.uid,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                  loading: () => ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  error: (error, stack) => ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading listings',
                              style: AppTypography.body(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                error.toString(),
                                style: AppTypography.bodySmall(
                                  color: AppColors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentGreen, width: 2),
      ),
      child: Icon(Icons.person, size: size * 0.5, color: AppColors.accentGreen),
    );
  }

  Widget _buildListingCard({
    required FoodListing listing,
    String? currentUserId,
  }) {
    final isDonor = currentUserId == listing.donorId;
    final requestCountAsync = isDonor
        ? ref.watch(
            listingRequestCountProvider(
              ListingRequestCountKey(
                listingId: listing.id,
                donorId: listing.donorId,
              ),
            ),
          )
        : null;
    final hasRequestedAsync =
        !isDonor && currentUserId != null && listing.isAvailable
        ? ref.watch(
            hasUserRequestedProvider(
              HasUserRequestedKey(
                listingId: listing.id,
                receiverId: currentUserId,
              ),
            ),
          )
        : null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: listing.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          listing.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                        if (listing.isUrgent)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Urgent',
                                    style: AppTypography.caption(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : _buildImagePlaceholder(),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: AppTypography.h3(
                          color: AppColors.pureWhite,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getFoodTypeColor(
                          listing.foodType,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getFoodTypeColor(listing.foodType),
                        ),
                      ),
                      child: Text(
                        _getFoodTypeLabel(listing.foodType),
                        style: AppTypography.caption(
                          color: _getFoodTypeColor(listing.foodType),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${listing.area}, ${listing.city}',
                        style: AppTypography.bodySmall(color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      color: AppColors.accentGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Serves ${listing.servings}',
                      style: AppTypography.bodySmall(
                        color: AppColors.accentGreen,
                      ),
                    ),
                    // Request count for donors
                    if (isDonor && requestCountAsync != null) ...[
                      const SizedBox(width: 16),
                      requestCountAsync.when(
                        data: (count) {
                          if (count > 0) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.notifications_active,
                                  color: AppColors.accentGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$count request${count > 1 ? 's' : ''}',
                                  style: AppTypography.bodySmall(
                                    color: AppColors.accentGreen,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                    // Requested status for receivers
                    if (!isDonor && hasRequestedAsync != null) ...[
                      const SizedBox(width: 16),
                      hasRequestedAsync.when(
                        data: (hasRequested) {
                          if (hasRequested) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.accentGreen,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.accentGreen,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Requested',
                                    style: AppTypography.caption(
                                      color: AppColors.accentGreen,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      color: listing.isUrgent ? Colors.orange : AppColors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatExpiryTime(listing.expiryDate),
                      style: AppTypography.bodySmall(
                        color: listing.isUrgent
                            ? Colors.orange
                            : AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(child: Icon(Icons.fastfood, size: 64, color: AppColors.grey));
  }

  Color _getFoodTypeColor(FoodType type) {
    switch (type) {
      case FoodType.cooked:
        return AppColors.accentGreen;
      case FoodType.packaged:
        return Colors.blue;
      case FoodType.bakery:
        return Colors.orange;
      case FoodType.beverages:
        return Colors.purple;
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

  String _formatExpiryTime(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.inHours < 6) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});
}
