import 'package:equatable/equatable.dart';

class ProfileStatsEntity extends Equatable {
  const ProfileStatsEntity({
    required this.totalOrders,
    required this.totalDelivered,
    required this.totalFailed,
    required this.totalCancelled,
    required this.successRate,
    required this.averageRating,
    required this.totalEarnings,
    required this.totalCommissions,
    required this.averageDeliveryTimeMinutes,
    required this.bestDay,
    required this.bestDayOrders,
  });

  final int totalOrders;
  final int totalDelivered;
  final int totalFailed;
  final int totalCancelled;
  final double successRate;
  final double averageRating;
  final double totalEarnings;
  final double totalCommissions;
  final double averageDeliveryTimeMinutes;
  final String? bestDay;
  final int bestDayOrders;

  @override
  List<Object?> get props => [
        totalOrders,
        totalDelivered,
        totalFailed,
        totalCancelled,
        successRate,
        averageRating,
        totalEarnings,
        totalCommissions,
        averageDeliveryTimeMinutes,
        bestDay,
        bestDayOrders,
      ];
}
