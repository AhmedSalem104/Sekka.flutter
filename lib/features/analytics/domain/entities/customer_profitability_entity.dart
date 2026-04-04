import 'package:equatable/equatable.dart';

class CustomerProfitabilityEntity extends Equatable {
  const CustomerProfitabilityEntity({
    required this.customerId,
    required this.customerName,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProfit,
    required this.averageOrderValue,
  });

  final String customerId;
  final String customerName;
  final int totalOrders;
  final double totalRevenue;
  final double totalProfit;
  final double averageOrderValue;

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        totalOrders,
        totalRevenue,
        totalProfit,
        averageOrderValue,
      ];
}
