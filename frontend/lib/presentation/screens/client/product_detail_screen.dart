import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../data/models/cart_item.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (p) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: p.fullImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: p.fullImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.categoryName != null)
                      Chip(
                        label: Text(p.categoryName!, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    const SizedBox(height: 8),
                    Text(p.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${p.price.toStringAsFixed(3)} TND',
                          style: const TextStyle(
                              fontSize: 26,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        _StockChip(stock: p.stockQuantity),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Description',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      p.description ?? 'Aucune description disponible.',
                      style: const TextStyle(height: 1.6, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: p.stockQuantity == 0
                            ? null
                            : () {
                                ref.read(cartProvider.notifier).addItem(CartItem(
                                      productId: p.id,
                                      productName: p.name,
                                      unitPrice: p.price,
                                      imageUrl: p.imageUrl,
                                    ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${p.name} ajouté au panier'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: Text(
                            p.stockQuantity == 0 ? 'Épuisé' : 'Ajouter au panier'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.car_repair, size: 64, color: Colors.grey)));
}

class _StockChip extends StatelessWidget {
  final int stock;
  const _StockChip({required this.stock});
  @override
  Widget build(BuildContext context) {
    final ok = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (ok ? AppTheme.success : AppTheme.error).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 14, color: ok ? AppTheme.success : AppTheme.error),
          const SizedBox(width: 4),
          Text(ok ? '$stock en stock' : 'Épuisé',
              style: TextStyle(
                  color: ok ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
