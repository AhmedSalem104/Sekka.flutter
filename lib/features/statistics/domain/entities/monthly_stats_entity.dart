import 'package:equatable/equatable.dart';

import 'weekly_stats_entity.dart';

class MonthlyStatsEntity extends Equatable {
  const MonthlyStatsEntity({
    required this.month,
    required this.year,
    required this.totalOrders,
    required this.successfulOrders,
    required this.earnings,
    required this.commissions,
    required this.expenses,
    required this.netProfit,
    required this.distanceKm,
    required this.timeWorkedMinutes,
    required this.successRate,
    required this.averageOrderValue,
    required this.averageDailyOrders,
    required this.averageDailyEarnings,
    required this.weeklyBreakdown,
    this.comparisonWithLastMonth,
  });

  final int month;
  final int year;
  final int totalOrders;
  final int successfulOrders;
  final double earnings;
  final double commissions;
  final double expenses;
  final double netProfit;
  final double distanceKm;
  final int timeWorkedMinutes;
  final double successRate;
  final double averageOrderValue;
  final double averageDailyOrders;
  final double averageDailyEarnings;
  final List<WeeklyBreakdown> weeklyBreakdown;
  final StatsComparison? comparisonWithLastMonth;

  @override
  List<Object?> get props => [month, year, totalOrders, earnings, netProfit];
}

class WeeklyBreakdown extends Equatable {
  const WeeklyBreakdown({
    required this.weekStart,
    required this.orders,
    required this.earnings,
  });

  final String weekStart;
  final int orders;
  final double earnings;

  @override
  List<Object?> get props => [weekStart, orders, earnings];
}
