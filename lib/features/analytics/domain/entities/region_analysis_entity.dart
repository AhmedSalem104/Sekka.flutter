import 'package:equatable/equatable.dart';

class RegionAnalysisEntity extends Equatable {
  const RegionAnalysisEntity({
    required this.region,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageDeliveryTime,
    required this.successRate,
  });

  final String region;
  final int totalOrders;
  final double totalRevenue;
  final double averageDeliveryTime;
  final double successRate;

  @override
  List<Object?> get props => [
        region,
        totalOrders,
        totalRevenue,
        averageDeliveryTime,
        successRate,
      ];
}
