import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/dashboard_stats.dart';
import '../network/dio_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  final Dio _dio;
  const ApiService(this._dio);

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<String> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data['token'] as String;
  }

  Future<String> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    });
    return res.data['token'] as String;
  }

  // ── Products ─────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts() async {
    final res = await _dio.get('/products');
    return (res.data as List).map((j) => ProductModel.fromJson(j)).toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return ProductModel.fromJson(res.data);
  }

  Future<ProductModel> createProduct(FormData form) async {
    final res = await _dio.post('/products', data: form);
    return ProductModel.fromJson(res.data);
  }

  Future<ProductModel> updateProduct(int id, FormData form) async {
    final res = await _dio.put('/products/$id', data: form);
    return ProductModel.fromJson(res.data);
  }

  Future<void> deleteProduct(int id) => _dio.delete('/products/$id');

  Future<List<ProductModel>> getLowStockProducts() async {
    final res = await _dio.get('/products/low-stock');
    return (res.data as List).map((j) => ProductModel.fromJson(j)).toList();
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    final res = await _dio.get('/categories');
    return (res.data as List).map((j) => CategoryModel.fromJson(j)).toList();
  }

  Future<CategoryModel> createCategory(String name) async {
    final res = await _dio.post('/categories', data: {'name': name});
    return CategoryModel.fromJson(res.data);
  }

  Future<void> deleteCategory(int id) => _dio.delete('/categories/$id');

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<OrderModel> placeOrder(List<Map<String, dynamic>> items) async {
    final res = await _dio.post('/orders', data: {'items': items});
    return OrderModel.fromJson(res.data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    final res = await _dio.get('/orders/my');
    return (res.data as List).map((j) => OrderModel.fromJson(j)).toList();
  }

  Future<List<OrderModel>> getAllOrders() async {
    final res = await _dio.get('/orders');
    return (res.data as List).map((j) => OrderModel.fromJson(j)).toList();
  }

  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    final res = await _dio.patch('/orders/$orderId/status', data: {'status': status});
    return OrderModel.fromJson(res.data);
  }

  // ── Quotes ────────────────────────────────────────────────────────────────

  Future<void> requestQuote(String message) =>
      _dio.post('/orders/quotes', data: {'message': message});

  // ── Dashboard─────────────────────────────────────────────────────────────

  Future<DashboardStats> getDashboardStats() async {
    final res = await _dio.get('/admin/stats');
    return DashboardStats.fromJson(res.data);
  }
}
