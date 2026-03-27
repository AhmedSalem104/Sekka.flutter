class CustomerEngagementModel {
  const CustomerEngagementModel({
    required this.engagementLevel,
    required this.ordersThisMonth,
    required this.ordersLastMonth,
    required this.daysSinceLastOrder,
    required this.averageOrdersPerMonth,
    required this.lifetimeValue,
    required this.retentionRisk,
  });

  final String engagementLevel;
  final int ordersThisMonth;
  final int ordersLastMonth;
  final int daysSinceLastOrder;
  final double averageOrdersPerMonth;
  final double lifetimeValue;
  final String retentionRisk;

  factory CustomerEngagementModel.fromJson(Map<String, dynamic> json) {
    return CustomerEngagementModel(
      engagementLevel: json['engagementLevel'] as String,
      ordersThisMonth: json['ordersThisMonth'] as int? ?? 0,
      ordersLastMonth: json['ordersLastMonth'] as int? ?? 0,
      daysSinceLastOrder: json['daysSinceLastOrder'] as int? ?? 0,
      averageOrdersPerMonth:
          (json['averageOrdersPerMonth'] as num?)?.toDouble() ?? 0.0,
      lifetimeValue: (json['lifetimeValue'] as num?)?.toDouble() ?? 0.0,
      retentionRisk: json['retentionRisk'] as String,
    );
  }
}
