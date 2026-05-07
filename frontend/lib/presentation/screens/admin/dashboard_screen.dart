import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (stats) {
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKPIHeader(stats.todayRevenue, stats.monthRevenue),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _StatCard(title: 'Commandes Total', value: '${stats.totalOrders}', icon: Icons.shopping_bag),
                  _StatCard(
                    title: 'En Attente',
                    value: '${stats.pendingOrders}',
                    icon: Icons.pending_actions,
                    color: AppTheme.warning,
                  ),
                  _StatCard(title: 'Total Produits', value: '${stats.totalProducts}', icon: Icons.inventory_2),
                  _StatCard(
                    title: 'Rupture de Stock',
                    value: '${stats.lowStockProducts}',
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.error,
                  ),
                ],
              ),
              if (stats.topProducts.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Top Produits Vendus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.topProducts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final p = stats.topProducts[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text('${i + 1}', style: const TextStyle(color: AppTheme.primary)),
                        ),
                        title: Text(p.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Text('${p.totalSold} vendus', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPIHeader(double today, double month) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenus Aujourd\'hui', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text('${today.toStringAsFixed(3)} TND', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Revenus ce mois', style: TextStyle(color: Colors.white70)),
              Text('${month.toStringAsFixed(3)} TND', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, this.color = AppTheme.primary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
