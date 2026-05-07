import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';
import '../data/services/api_service.dart';

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.watch(apiServiceProvider).getProducts();
});

final productDetailProvider =
    FutureProvider.family<ProductModel, int>((ref, id) async {
  return ref.watch(apiServiceProvider).getProduct(id);
});
