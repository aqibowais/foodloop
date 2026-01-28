import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/models/complaint_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String? listingId;
  final String? againstUserId;

  const ReportScreen({super.key, this.listingId, this.againstUserId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  ComplaintCategory _selectedCategory = ComplaintCategory.other;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      AppToast.error(context, 'Please login to submit a complaint');
      return;
    }

    // If no listingId provided, user can still submit a general complaint
    // For now, we'll require a listingId, but in the future we can make it optional
    if (widget.listingId == null) {
      AppToast.error(context, 'Please report from a specific listing');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(complaintControllerProvider.notifier);
      final success = await controller.submitComplaint(
        listingId: widget.listingId!,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        againstUserId: widget.againstUserId,
      );

      if (mounted) {
        if (success) {
          AppToast.success(context, 'Complaint submitted successfully');
          Navigator.pop(context);
        } else {
          final state = ref.read(complaintControllerProvider);
          AppToast.error(context, state.error ?? 'Failed to submit complaint');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Issue',
          style: AppTypography.h3(color: AppColors.pureWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Help us improve by reporting any issues you\'ve encountered.',
                style: AppTypography.body(color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              // Category selection
              Text(
                'Category',
                style: AppTypography.h3(color: AppColors.pureWhite),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: ComplaintCategory.values.map((category) {
                    String label;
                    IconData icon;
                    switch (category) {
                      case ComplaintCategory.foodQuality:
                        label = 'Food Quality';
                        icon = Icons.restaurant;
                        break;
                      case ComplaintCategory.pickupIssue:
                        label = 'Pickup Issue';
                        icon = Icons.local_shipping;
                        break;
                      case ComplaintCategory.userBehavior:
                        label = 'User Behavior';
                        icon = Icons.person_off;
                        break;
                      case ComplaintCategory.listingIssue:
                        label = 'Listing Issue';
                        icon = Icons.description;
                        break;
                      case ComplaintCategory.other:
                        label = 'Other';
                        icon = Icons.more_horiz;
                        break;
                    }
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                label,
                                style: AppTypography.body(
                                  color: isSelected
                                      ? AppColors.black
                                      : AppColors.pureWhite,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.black,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Description',
                style: AppTypography.h3(color: AppColors.pureWhite),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the issue';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
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
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.black,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Submit Report',
                              style: AppTypography.button(
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
