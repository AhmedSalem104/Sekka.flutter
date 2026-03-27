import 'package:equatable/equatable.dart';

class WeeklyStatsEntity extends Equatable {
  const WeeklyStatsEntity({
    required this.weekStart,
    required this.weekEnd,
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
    required this.dailyBreakdown,
    this.bestDay,
    this.worstDay,
    this.comparisonWithLastWeek,
  });

  final String weekStart;
  final String weekEnd;
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
  final List<DailyBreakdown> dailyBreakdown;
  final String? bestDay;
  final String? worstDay;
  final StatsComparison? comparisonWithLastWeek;

  @override
  List<Object?> get props => [weekStart, totalOrders, earnings, netProfit];
}

class DailyBreakdown extends Equatable {
  const DailyBreakdown({
    required this.date,
    required this.orders,
    required this.earnings,
  });

  final String date;
  final int orders;
  final double earnings;

  @override
  List<Object?> get props => [date, orders, earnings];
}

class StatsComparison extends Equatable {
  const StatsComparison({
    required this.ordersChange,
    required this.earningsChange,
    required this.successRateChange,
  });

  final double ordersChange;
  final double earningsChange;
  final double successRateChange;

  @override
  List<Object?> get props => [ordersChange, earningsChange, successRateChange];
}
