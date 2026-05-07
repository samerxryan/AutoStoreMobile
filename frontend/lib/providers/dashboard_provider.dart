import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dashboard_stats.dart';
import '../data/services/api_service.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  return ref.watch(apiServiceProvider).getDashboardStats();
});
