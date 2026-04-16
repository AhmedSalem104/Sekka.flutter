import 'package:equatable/equatable.dart';

class DailyStatsEntity extends Equatable {
  const DailyStatsEntity({
    required this.date,
    required this.totalOrders,
    required this.successfulOrders,
    required this.failedOrders,
    required this.cancelledOrders,
    required this.earnings,
    required this.commissions,
    required this.expenses,
    required this.netProfit,
    required this.distanceKm,
    required this.timeWorkedMinutes,
    required this.successRate,
    required this.averageOrderValue,
    required this.averageDeliveryTimeMinutes,
    required this.tips,
    required this.peakHour,
    required this.peakHourOrders,
    this.bestRegion,
    this.bestTimeSlot,
    this.postponedOrders = 0,
  });

  final String date;
  final int totalOrders;
  final int successfulOrders;
  final int failedOrders;
  final int cancelledOrders;
  final double earnings;
  final double commissions;
  final double expenses;
  final double netProfit;
  final double distanceKm;
  final int timeWorkedMinutes;
  final double successRate;
  final double averageOrderValue;
  final int averageDeliveryTimeMinutes;
  final double tips;
  final int peakHour;
  final int peakHourOrders;
  final String? bestRegion;
  final String? bestTimeSlot;
  final int postponedOrders;

  @override
  List<Object?> get props => [date, totalOrders, earnings, netProfit];
}
