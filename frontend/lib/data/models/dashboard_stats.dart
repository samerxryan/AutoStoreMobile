class DashboardStats {
  final double todayRevenue;
  final double monthRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int totalProducts;
  final int lowStockProducts;
  final List<DailyStat> dailyRevenue;
  final List<TopProduct> topProducts;

  const DashboardStats({
    required this.todayRevenue,
    required this.monthRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.dailyRevenue,
    required this.topProducts,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        todayRevenue: (json['todayRevenue'] as num).toDouble(),
        monthRevenue: (json['monthRevenue'] as num).toDouble(),
        totalOrders: json['totalOrders'] ?? 0,
        pendingOrders: json['pendingOrders'] ?? 0,
        totalProducts: json['totalProducts'] ?? 0,
        lowStockProducts: json['lowStockProducts'] ?? 0,
        dailyRevenue: (json['dailyRevenue'] as List? ?? [])
            .map((d) => DailyStat.fromJson(d))
            .toList(),
        topProducts: (json['topProducts'] as List? ?? [])
            .map((p) => TopProduct.fromJson(p))
            .toList(),
      );
}

class DailyStat {
  final String date;
  final double revenue;
  const DailyStat({required this.date, required this.revenue});
  factory DailyStat.fromJson(Map<String, dynamic> json) =>
      DailyStat(date: json['date'], revenue: (json['revenue'] as num).toDouble());
}

class TopProduct {
  final String productName;
  final int totalSold;
  const TopProduct({required this.productName, required this.totalSold});
  factory TopProduct.fromJson(Map<String, dynamic> json) =>
      TopProduct(productName: json['productName'], totalSold: json['totalSold'] ?? 0);
}
