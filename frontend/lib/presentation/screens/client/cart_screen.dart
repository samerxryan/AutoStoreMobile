import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: notifier.clear,
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              label: const Text('Vider', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Votre panier est vide',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Parcourir les produits'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final item = cart[i];
                final imgUrl = item.imageUrl != null
                    ? '${AppConstants.uploadBaseUrl}${item.imageUrl}'
                    : '';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: imgUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imgUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.car_repair, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                '${item.unitPrice.toStringAsFixed(3)} TND',
                                style: const TextStyle(color: AppTheme.primary, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: () => notifier.decrement(item.productId),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  _QtyBtn(
                                    icon: Icons.add,
                                    onTap: () => notifier.increment(item.productId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => notifier.removeItem(item.productId),
                            ),
                            Text(
                              '${item.subtotal.toStringAsFixed(3)} TND',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${notifier.total.toStringAsFixed(3)} TND',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/checkout'),
                        icon: const Icon(Icons.payment),
                        label: const Text('Passer la commande'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18),
        ),
      );
}
