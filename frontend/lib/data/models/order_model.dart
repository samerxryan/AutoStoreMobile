class OrderItemModel {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'],
        productName: json['productName'] ?? '',
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

class OrderModel {
  final int id;
  final int clientId;
  final String clientEmail;
  final double totalAmount;
  final String status;
  final String orderDate;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.clientId,
    required this.clientEmail,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        clientId: json['clientId'],
        clientEmail: json['clientEmail'] ?? '',
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] ?? 'PENDING',
        orderDate: json['orderDate']?.toString() ?? '',
        items: (json['items'] as List? ?? [])
            .map((i) => OrderItemModel.fromJson(i))
            .toList(),
      );
}
