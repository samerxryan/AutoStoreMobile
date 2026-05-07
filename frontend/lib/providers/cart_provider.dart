import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem newItem) {
    final existing = state.where((i) => i.productId == newItem.productId);
    if (existing.isNotEmpty) {
      state = [
        for (final item in state)
          if (item.productId == newItem.productId)
            CartItem(
              productId: item.productId,
              productName: item.productName,
              unitPrice: item.unitPrice,
              imageUrl: item.imageUrl,
              quantity: item.quantity + 1,
            )
          else
            item,
      ];
    } else {
      state = [...state, newItem];
    }
  }

  void removeItem(int productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void increment(int productId) {
    state = [
      for (final item in state)
        if (item.productId == productId)
          CartItem(
            productId: item.productId,
            productName: item.productName,
            unitPrice: item.unitPrice,
            imageUrl: item.imageUrl,
            quantity: item.quantity + 1,
          )
        else
          item,
    ];
  }

  void decrement(int productId) {
    state = [
      for (final item in state)
        if (item.productId == productId && item.quantity > 1)
          CartItem(
            productId: item.productId,
            productName: item.productName,
            unitPrice: item.unitPrice,
            imageUrl: item.imageUrl,
            quantity: item.quantity - 1,
          )
        else if (item.productId == productId && item.quantity == 1)
          ...[] // drop it
        else
          item,
    ];
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, i) => sum + i.subtotal);
  int get itemCount => state.fold(0, (sum, i) => sum + i.quantity);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
