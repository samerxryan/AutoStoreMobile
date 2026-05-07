class CartItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.imageUrl,
    this.quantity = 1,
  });

  double get subtotal => quantity * unitPrice;
}
