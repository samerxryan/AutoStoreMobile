import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/order_provider.dart';
import '../../../data/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (list) {
          final sorted = [...list]..sort((a, b) => b.orderDate.compareTo(a.orderDate));
          if (sorted.isEmpty) return const Center(child: Text('Aucune commande.'));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allOrdersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (ctx, i) {
                final o = sorted[i];

                DateTime? date;
                try {
                  date = DateTime.parse(o.orderDate);
                } catch (_) {}
                final dateStr = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : o.orderDate;

                return Card(
                  child: ExpansionTile(
                    title: Text('Commande #${o.id} - ${o.clientEmail}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$dateStr | Total: ${o.totalAmount.toStringAsFixed(3)} TND'),
                    trailing: _buildStatusDropdown(context, ref, o.id, o.status),
                    children: [
                      const Divider(),
                      ...o.items.map((it) => ListTile(
                            dense: true,
                            title: Text(it.productName),
                            trailing: Text('${it.quantity} x ${it.unitPrice} TND'),
                          )),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext ctx, WidgetRef ref, int orderId, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      items: const [
        DropdownMenuItem(value: 'PENDING', child: Text('PENDING', style: TextStyle(color: AppTheme.warning))),
        DropdownMenuItem(value: 'CONFIRMED', child: Text('CONFIRMED', style: TextStyle(color: AppTheme.primary))),
        DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED', style: TextStyle(color: AppTheme.success))),
        DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED', style: TextStyle(color: AppTheme.error))),
      ],
      onChanged: (newStatus) async {
        if (newStatus == null || newStatus == currentStatus) return;
        try {
          await ref.read(apiServiceProvider).updateOrderStatus(orderId, newStatus);
          ref.invalidate(allOrdersProvider);
        } catch (e) {
          if (!ctx.mounted) return;
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      },
    );
  }
}
