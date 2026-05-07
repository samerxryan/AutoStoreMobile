import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/order_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aucune commande trouvée.'));
          }

          // Sort orders by most recent
          final sortedList = [...list]..sort((a, b) => b.orderDate.compareTo(a.orderDate));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final o = sortedList[index];
                
                DateTime? date;
                try {
                  date = DateTime.parse(o.orderDate);
                } catch (_) {}
                final dateStr = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : o.orderDate;

                Color statusColor;
                switch (o.status) {
                  case 'CONFIRMED':
                    statusColor = AppTheme.success;
                    break;
                  case 'DELIVERED':
                    statusColor = AppTheme.primary;
                    break;
                  case 'CANCELLED':
                    statusColor = AppTheme.error;
                    break;
                  default:
                    statusColor = AppTheme.warning;
                }

                return Card(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        'Commande #${o.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateStr, style: const TextStyle(fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                o.status,
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        const Divider(),
                        ...o.items.map((i) => ListTile(
                              dense: true,
                              title: Text(i.productName),
                              trailing: Text('${i.quantity} x ${i.unitPrice} TND'),
                            )),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '${o.totalAmount.toStringAsFixed(3)} TND',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
