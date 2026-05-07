import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/order_model.dart';
import '../data/services/api_service.dart';

final myOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(apiServiceProvider).getMyOrders();
});

final allOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(apiServiceProvider).getAllOrders();
});
