import '../../domain/entities/customer_profitability_entity.dart';

class CustomerProfitabilityModel extends CustomerProfitabilityEntity {
  const CustomerProfitabilityModel({
    required super.customerId,
    required super.customerName,
    required super.totalOrders,
    required super.totalRevenue,
    required super.totalProfit,
    required super.averageOrderValue,
  });

  factory CustomerProfitabilityModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfitabilityModel(
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalProfit: (json['totalProfit'] as num?)?.toDouble() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'customerName': customerName,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'totalProfit': totalProfit,
        'averageOrderValue': averageOrderValue,
      };
}
