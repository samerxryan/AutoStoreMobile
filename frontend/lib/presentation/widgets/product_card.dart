import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/product_model.dart';
import '../../../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.fullImageUrl.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: product.fullImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.categoryName!,
                        style: const TextStyle(fontSize: 10, color: AppTheme.primary),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(3)} DT',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      _stockBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.car_repair, size: 40, color: Colors.grey)),
      );

  Widget _stockBadge() {
    final inStock = product.stockQuantity > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (inStock ? AppTheme.success : AppTheme.error).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        inStock ? '${product.stockQuantity} en stock' : 'Épuisé',
        style: TextStyle(
          fontSize: 10,
          color: inStock ? AppTheme.success : AppTheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Shimmer skeleton for product loading
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(aspectRatio: 1.1, child: Container(color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 10, width: 60, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 12, width: double.infinity, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 12, width: 100, color: Colors.white),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
