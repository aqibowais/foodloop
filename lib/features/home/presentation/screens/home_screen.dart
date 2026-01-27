import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../user/providers/user_provider.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.user;

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
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.body(color: AppColors.pureWhite),
                  decoration: InputDecoration(
                    hintText: 'Search food listings...',
                    hintStyle: AppTypography.body(color: AppColors.grey),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.grey,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Category filters
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Available Listings section
                  Row(
                    children: [
                      Text(
                        'Available Listings',
                        style: AppTypography.h3(
                          color: AppColors.pureWhite,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Placeholder listing cards
                  _buildListingCard(
                    title: 'Fresh Biryani',
                    location: 'Gulberg, Lahore',
                    servings: 'Serves 4-5 people',
                    imageUrl: null,
                  ),
                  const SizedBox(height: 16),
                  _buildListingCard(
                    title: 'Packaged Snacks',
                    location: 'DHA, Karachi',
                    servings: 'Multiple items',
                    imageUrl: null,
                  ),
                  const SizedBox(height: 16),
                  _buildListingCard(
                    title: 'Leftover Pizza',
                    location: 'F-7, Islamabad',
                    servings: 'Serves 2-3 people',
                    imageUrl: null,
                  ),
                  const SizedBox(height: 24),
                  // Popular Food section
                  Row(
                    children: [
                      Text(
                        'Popular Food',
                        style: AppTypography.h3(
                          color: AppColors.pureWhite,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Empty state for now
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
                          'No listings yet',
                          style: AppTypography.body(color: AppColors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share food!',
                          style: AppTypography.bodySmall(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', true),
                _buildNavItem(Icons.notifications_outlined, 'Notifications', false),
                _buildNavItem(Icons.shopping_cart_outlined, 'My Orders', false),
                _buildNavItem(Icons.person_outline, 'Profile', false, onTap: _navigateToProfile),
              ],
            ),
          ),
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
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.accentGreen,
      ),
    );
  }

  Widget _buildListingCard({
    required String title,
    required String location,
    required String servings,
    String? imageUrl,
  }) {
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
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
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
                Text(
                  title,
                  style: AppTypography.h3(
                    color: AppColors.pureWhite,
                    fontSize: 18,
                  ),
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
                    Text(
                      location,
                      style: AppTypography.bodySmall(color: AppColors.grey),
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
                      servings,
                      style: AppTypography.bodySmall(
                        color: AppColors.accentGreen,
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
    return Center(
      child: Icon(
        Icons.fastfood,
        size: 64,
        color: AppColors.grey,
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.accentGreen : AppColors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption(
              color: isSelected ? AppColors.accentGreen : AppColors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;

  const _CategoryItem({
    required this.icon,
    required this.label,
  });
}

