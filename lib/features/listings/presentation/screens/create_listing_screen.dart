import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/food_listing_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../providers/listings_provider.dart';
import '../../../../features/user/providers/user_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _addressController = TextEditingController();

  FoodType _selectedFoodType = FoodType.cooked;
  DateTime? _selectedExpiryDate;
  TimeOfDay? _selectedExpiryTime;
  List<File> _selectedImages = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((xFile) => File(xFile.path)).toList();
        });
      }
    } catch (e) {
      AppToast.error(context, 'Failed to pick images: $e');
    }
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 30));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 6)),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentGreen,
              onPrimary: AppColors.black,
              surface: AppColors.cardDark,
              onSurface: AppColors.pureWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.accentGreen,
                onPrimary: AppColors.black,
                surface: AppColors.cardDark,
                onSurface: AppColors.pureWhite,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedExpiryDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedExpiryTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      AppToast.error(context, 'Please add at least one image');
      return;
    }

    if (_selectedExpiryDate == null) {
      AppToast.error(context, 'Please select expiry date and time');
      return;
    }

    final userState = ref.read(userControllerProvider);
    final user = userState.user;
    if (user == null) {
      AppToast.error(context, 'User not logged in');
      return;
    }
    if (user.city == null || user.area == null) {
      AppToast.error(
        context,
        'Please set your city and area in profile settings',
      );
      return;
    }

    final controller = ref.read(listingsControllerProvider.notifier);
    final success = await controller.createListing(
      foodType: _selectedFoodType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      servings: int.parse(_servingsController.text.trim()),
      expiryDate: _selectedExpiryDate!,
      city: user.city!,
      area: user.area!,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      imageFiles: _selectedImages,
    );

    if (success && mounted) {
      AppToast.success(context, 'Listing created successfully!');
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(listingsControllerProvider).error;
      AppToast.error(
        context,
        error ?? 'Failed to create listing. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsState = ref.watch(listingsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(
          'Create Listing',
          style: AppTypography.h3(color: AppColors.pureWhite),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Food Type Selection
                Text(
                  'Food Type',
                  style: AppTypography.h3(color: AppColors.pureWhite),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: FoodType.values.map((type) {
                    final isSelected = _selectedFoodType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFoodType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentGreen
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
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
                              _getFoodTypeIcon(type),
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.pureWhite,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getFoodTypeLabel(type),
                              style: AppTypography.body(
                                color: isSelected
                                    ? AppColors.black
                                    : AppColors.pureWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'e.g., Fresh Biryani, Packaged Snacks',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.length < 5) {
                      return 'Title must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe the food item...',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Servings
                _buildTextField(
                  controller: _servingsController,
                  label: 'Number of Servings',
                  hint: 'e.g., 4',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of servings';
                    }
                    final servings = int.tryParse(value);
                    if (servings == null || servings < 1) {
                      return 'Please enter a valid number (at least 1)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiry Date/Time
                Text(
                  'Expiry / Best Before',
                  style: AppTypography.body(
                    color: AppColors.pureWhite,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectExpiryDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.accentGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedExpiryDate != null
                                ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year} ${_selectedExpiryTime!.format(context)}'
                                : 'Select date and time',
                            style: AppTypography.body(
                              color: _selectedExpiryDate != null
                                  ? AppColors.pureWhite
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address (optional)
                _buildTextField(
                  controller: _addressController,
                  label: 'Detailed Address (Optional)',
                  hint: 'e.g., House #123, Street Name',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Images
                Text(
                  'Food Images',
                  style: AppTypography.body(
                    color: AppColors.pureWhite,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.lightGrey,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _selectedImages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate,
                                  color: AppColors.accentGreen,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add images',
                                  style: AppTypography.bodySmall(
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.black,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: AppColors.pureWhite,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: listingsState.isCreating ||
                            listingsState.isUploadingImages
                        ? null
                        : _submitListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: listingsState.isCreating ||
                            listingsState.isUploadingImages
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Listing',
                                style: AppTypography.button(
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle, size: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body(
            color: AppColors.pureWhite,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.body(color: AppColors.pureWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body(color: AppColors.grey),
            prefixIcon: Icon(icon, color: AppColors.accentGreen),
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
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

