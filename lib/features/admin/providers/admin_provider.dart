import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/complaint_model.dart';
import '../services/admin_service.dart';

/// Admin service provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

/// All complaints provider
final allComplaintsProvider = StreamProvider<List<Complaint>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getAllComplaints();
});

/// Analytics provider
final adminAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return await service.getAnalytics();
});

