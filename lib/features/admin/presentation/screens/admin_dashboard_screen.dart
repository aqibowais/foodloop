import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:foodloop/core/navigation/page_transitions.dart';
import 'package:foodloop/features/admin/providers/admin_provider.dart';
import 'package:foodloop/features/auth/presentation/screens/login_screen.dart';
import 'package:foodloop/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/models/complaint_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedTab = 0; // 0: Analytics, 1: Complaints
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
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: AppTypography.h3(color: AppColors.pureWhite),
        ),
        actions: [
          //logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.pureWhite),
            onPressed: () {
              ref.invalidate(adminAnalyticsProvider);
              ref.invalidate(allComplaintsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Analytics', 0)),
                Expanded(child: _buildTabButton('Complaints', 1)),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildAnalyticsTab()
                : _buildComplaintsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.button(
            color: isSelected ? AppColors.black : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final analyticsAsync = ref.watch(adminAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Listings',
                    analytics['totalListings'] ?? 0,
                    Icons.restaurant,
                    AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Requests',
                    analytics['totalRequests'] ?? 0,
                    Icons.request_quote,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    analytics['totalUsers'] ?? 0,
                    Icons.people,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Complaints',
                    analytics['totalComplaints'] ?? 0,
                    Icons.report_problem,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Listing Status Chart
            Text(
              'Listing Status',
              style: AppTypography.h3(color: AppColors.pureWhite),
            ),
            const SizedBox(height: 12),
            _buildListingStatusChart(analytics),
            const SizedBox(height: 24),
            // Request Status Chart
            Text(
              'Request Status',
              style: AppTypography.h3(color: AppColors.pureWhite),
            ),
            const SizedBox(height: 12),
            _buildRequestStatusChart(analytics),
            const SizedBox(height: 24),
            // Complaint Status Chart
            Text(
              'Complaint Status',
              style: AppTypography.h3(color: AppColors.pureWhite),
            ),
            const SizedBox(height: 12),
            _buildComplaintStatusChart(analytics),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: AppTypography.body(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.bodySmall(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value.toString(),
                style: AppTypography.h2(color: AppColors.pureWhite),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.bodySmall(color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildListingStatusChart(Map<String, dynamic> analytics) {
    final available = analytics['availableListings'] ?? 0;
    final reserved = analytics['reservedListings'] ?? 0;
    final completed = analytics['completedListings'] ?? 0;
    final expired = analytics['expiredListings'] ?? 0;
    final total = available + reserved + completed + expired;

    if (total == 0) {
      return _buildEmptyChart('No listings data');
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            _buildPieSection(available, AppColors.accentGreen, 'Available'),
            _buildPieSection(reserved, Colors.orange, 'Reserved'),
            _buildPieSection(completed, Colors.blue, 'Completed'),
            _buildPieSection(expired, Colors.red, 'Expired'),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildRequestStatusChart(Map<String, dynamic> analytics) {
    final pending = analytics['pendingRequests'] ?? 0;
    final accepted = analytics['acceptedRequests'] ?? 0;
    final rejected = analytics['rejectedRequests'] ?? 0;
    final total = pending + accepted + rejected;

    if (total == 0) {
      return _buildEmptyChart('No requests data');
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: total.toDouble() + 5,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text(
                        'Pending',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      );
                    case 1:
                      return const Text(
                        'Accepted',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      );
                    case 2:
                      return const Text(
                        'Rejected',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      );
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: pending.toDouble(),
                  color: Colors.orange,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: accepted.toDouble(),
                  color: AppColors.accentGreen,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: rejected.toDouble(),
                  color: Colors.red,
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintStatusChart(Map<String, dynamic> analytics) {
    final submitted = analytics['submittedComplaints'] ?? 0;
    final underReview = analytics['underReviewComplaints'] ?? 0;
    final resolved = analytics['resolvedComplaints'] ?? 0;
    final total = submitted + underReview + resolved;

    if (total == 0) {
      return _buildEmptyChart('No complaints data');
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            _buildPieSection(submitted, Colors.orange, 'Submitted'),
            _buildPieSection(underReview, Colors.blue, 'Under Review'),
            _buildPieSection(resolved, AppColors.accentGreen, 'Resolved'),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(int value, Color color, String label) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      title: value > 0 ? value.toString() : '',
      radius: 50,
      titleStyle: AppTypography.caption(color: AppColors.black, fontSize: 12),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message, style: AppTypography.body(color: AppColors.grey)),
      ),
    );
  }

  Widget _buildComplaintsTab() {
    final complaintsAsync = ref.watch(allComplaintsProvider);

    return complaintsAsync.when(
      data: (complaints) {
        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey),
                const SizedBox(height: 16),
                Text(
                  'No complaints yet',
                  style: AppTypography.h3(color: AppColors.pureWhite),
                ),
                const SizedBox(height: 8),
                Text(
                  'All clear!',
                  style: AppTypography.body(color: AppColors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            return _buildComplaintCard(complaint);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading complaints',
              style: AppTypography.body(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.bodySmall(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    Color statusColor;
    String statusLabel;
    switch (complaint.status) {
      case ComplaintStatus.submitted:
        statusColor = Colors.orange;
        statusLabel = 'Submitted';
        break;
      case ComplaintStatus.underReview:
        statusColor = Colors.blue;
        statusLabel = 'Under Review';
        break;
      case ComplaintStatus.resolved:
        statusColor = AppColors.accentGreen;
        statusLabel = 'Resolved';
        break;
    }

    String categoryLabel;
    switch (complaint.category) {
      case ComplaintCategory.foodQuality:
        categoryLabel = 'Food Quality';
        break;
      case ComplaintCategory.pickupIssue:
        categoryLabel = 'Pickup Issue';
        break;
      case ComplaintCategory.userBehavior:
        categoryLabel = 'User Behavior';
        break;
      case ComplaintCategory.listingIssue:
        categoryLabel = 'Listing Issue';
        break;
      case ComplaintCategory.other:
        categoryLabel = 'Other';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryLabel,
                      style: AppTypography.body(color: AppColors.pureWhite),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM d, y • h:mm a',
                      ).format(complaint.createdAt),
                      style: AppTypography.caption(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.caption(
                    color: statusColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            complaint.description,
            style: AppTypography.bodySmall(color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          // Status dropdown
          DropdownButtonFormField<ComplaintStatus>(
            value: complaint.status,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            dropdownColor: AppColors.cardDark,
            style: AppTypography.body(color: AppColors.pureWhite),
            items: ComplaintStatus.values.map((status) {
              String label;
              switch (status) {
                case ComplaintStatus.submitted:
                  label = 'Submitted';
                  break;
                case ComplaintStatus.underReview:
                  label = 'Under Review';
                  break;
                case ComplaintStatus.resolved:
                  label = 'Resolved';
                  break;
              }
              return DropdownMenuItem(value: status, child: Text(label));
            }).toList(),
            onChanged: (newStatus) {
              if (newStatus != null) {
                _updateComplaintStatus(complaint.id, newStatus);
              }
            },
          ),
          if (complaint.adminNotes != null &&
              complaint.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Notes:',
                    style: AppTypography.caption(color: AppColors.accentGreen),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.adminNotes!,
                    style: AppTypography.bodySmall(color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateComplaintStatus(
    String complaintId,
    ComplaintStatus newStatus,
  ) async {
    try {
      final service = ref.read(adminServiceProvider);
      await service.updateComplaintStatus(complaintId, newStatus);
      if (mounted) {
        AppToast.success(context, 'Complaint status updated');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to update status: $e');
      }
    }
  }
}
