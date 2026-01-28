import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodloop/core/navigation/page_transitions.dart';
import 'package:foodloop/features/auth/presentation/screens/login_screen.dart';
import 'package:foodloop/features/auth/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../providers/profile_provider.dart';
import '../../../user/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _organizationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _organizationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final userState = ref.read(userControllerProvider);
    final user = userState.user;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _cityController.text = user.city ?? '';
      _areaController.text = user.area ?? '';
      _organizationController.text = user.organizationName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return;

      final profileController = ref.read(profileControllerProvider.notifier);
      final success = await profileController.uploadProfileImage(
        File(image.path),
      );

      if (!mounted) return;

      if (success) {
        AppToast.success(context, 'Profile image updated');
      } else {
        final state = ref.read(profileControllerProvider);
        AppToast.error(context, state.error ?? 'Failed to update image');
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileController = ref.read(profileControllerProvider.notifier);
    final success = await profileController.updateProfile(
      displayName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      area: _areaController.text.trim().isEmpty
          ? null
          : _areaController.text.trim(),
      organizationName: _organizationController.text.trim().isEmpty
          ? null
          : _organizationController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      AppToast.success(context, 'Profile updated successfully');
    } else {
      final state = ref.read(profileControllerProvider);
      AppToast.error(context, state.error ?? 'Failed to update profile');
    }
  }

  void _cancelEdit() {
    _loadUserData();
    ref.read(profileControllerProvider.notifier).cancelEditing();
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;

    // Immediately navigate to the login/auth screen and remove all previous routes.
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      FadePageRoute(child: const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final user = userState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      );
    }

    final isEditing = profileState.isEditing;
    final isUploadingImage = profileState.isUploadingImage;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTypography.h3(color: AppColors.pureWhite),
        ),
        actions: [
          if (!isEditing)
            TextButton(
              onPressed: () {
                ref.read(profileControllerProvider.notifier).toggleEditMode();
              },
              child: Text(
                'Edit',
                style: AppTypography.button(color: AppColors.accentGreen),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _cancelEdit,
                  child: Text(
                    'Cancel',
                    style: AppTypography.button(color: AppColors.grey),
                  ),
                ),
                TextButton(
                  onPressed: userState.isLoading ? null : _saveProfile,
                  child: userState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentGreen,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTypography.button(
                            color: AppColors.accentGreen,
                          ),
                        ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Profile image
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: user.photoUrl != null
                          ? Image.network(
                              user.photoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderAvatar(120);
                              },
                            )
                          : _buildPlaceholderAvatar(120),
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.black,
                              width: 3,
                            ),
                          ),
                          child: IconButton(
                            icon: isUploadingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.black,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.black,
                                    size: 20,
                                  ),
                            onPressed: isUploadingImage ? null : _pickImage,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Email (disabled)
              _buildProfileTextField(
                controller: TextEditingController(text: user.email),
                hint: 'Email',
                icon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 16),
              // Role (read-only)
              _buildProfileTextField(
                controller: TextEditingController(
                  text: user.isAdmin ? 'Admin' : 'User',
                ),
                hint: 'Role',
                icon: Icons.person_outline,
                enabled: false,
              ),
              const SizedBox(height: 16),
              // Display Name
              _buildProfileTextField(
                controller: _nameController,
                hint: 'Full Name',
                icon: Icons.person,
                enabled: isEditing,
                validator: (value) {
                  if (isEditing && value != null && value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // City
              _buildProfileTextField(
                controller: _cityController,
                hint: 'City',
                icon: Icons.location_city,
                enabled: isEditing,
              ),
              const SizedBox(height: 16),
              // Area
              _buildProfileTextField(
                controller: _areaController,
                hint: 'Area / Locality',
                icon: Icons.place,
                enabled: isEditing,
              ),
              const SizedBox(height: 16),
              // Organization Name
              _buildProfileTextField(
                controller: _organizationController,
                hint: 'Organization Name (Optional)',
                icon: Icons.business,
                enabled: isEditing,
                extraHint: 'Leave empty if individual donor/receiver',
              ),
              const SizedBox(height: 16),
              // Phone Number
              _buildProfileTextField(
                controller: _phoneController,
                hint: 'Phone Number (Optional)',
                icon: Icons.phone_outlined,
                enabled: isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (isEditing && value != null && value.trim().isNotEmpty) {
                    if (!PhoneValidator.isValidPakistaniPhone(value.trim())) {
                      return 'Please enter a valid Pakistani phone number (e.g., 03XX-XXXXXXX)';
                    }
                  }
                  return null;
                },
                extraHint: 'Format: 03XX-XXXXXXX or +923XXXXXXXXX',
              ),
              const SizedBox(height: 24),
              // Info text
              if (isEditing)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Organization name is optional. Fill it if you\'re registering as an NGO or organization.',
                          style: AppTypography.bodySmall(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Logout button section (moved from AppBar)
              Center(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(
                      color: AppColors.accentGreen,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.accentGreen,
                    size: 22,
                  ),
                  label: Text(
                    'Logout',
                    style: AppTypography.button(color: AppColors.accentGreen),
                  ),
                  onPressed: _logout,
                ),
              ),
              const SizedBox(height: 24),
            ],
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
        border: Border.all(color: AppColors.lightGrey, width: 2),
      ),
      child: Icon(Icons.person, size: size * 0.5, color: AppColors.grey),
    );
  }

  /// Build a text field that matches the login textfield design.
  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    String? extraHint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
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
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        if (extraHint != null && enabled)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              extraHint,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
