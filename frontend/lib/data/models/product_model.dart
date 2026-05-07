import '../../core/constants/app_constants.dart';

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
  });

  String get fullImageUrl {
    if (imageUrl == null) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    return '${AppConstants.uploadBaseUrl}$imageUrl';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        stockQuantity: json['stockQuantity'] ?? 0,
        imageUrl: json['imageUrl'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
      );
}
