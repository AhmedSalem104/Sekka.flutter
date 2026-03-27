import '../../domain/entities/monthly_stats_entity.dart';
import 'weekly_stats_model.dart';

class MonthlyStatsModel extends MonthlyStatsEntity {
  const MonthlyStatsModel({
    required super.month,
    required super.year,
    required super.totalOrders,
    required super.successfulOrders,
    required super.earnings,
    required super.commissions,
    required super.expenses,
    required super.netProfit,
    required super.distanceKm,
    required super.timeWorkedMinutes,
    required super.successRate,
    required super.averageOrderValue,
    required super.averageDailyOrders,
    required super.averageDailyEarnings,
    required super.weeklyBreakdown,
    super.comparisonWithLastMonth,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsModel(
      month: json['month'] as int? ?? 1,
      year: json['year'] as int? ?? 2026,
      totalOrders: json['totalOrders'] as int? ?? 0,
      successfulOrders: json['successfulOrders'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
      commissions: (json['commissions'] as num?)?.toDouble() ?? 0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      timeWorkedMinutes: json['timeWorkedMinutes'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
      averageDailyOrders:
          (json['averageDailyOrders'] as num?)?.toDouble() ?? 0,
      averageDailyEarnings:
          (json['averageDailyEarnings'] as num?)?.toDouble() ?? 0,
      weeklyBreakdown: (json['weeklyBreakdown'] as List?)
              ?.map((e) => WeeklyBreakdownModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      comparisonWithLastMonth: json['comparisonWithLastMonth'] != null
          ? StatsComparisonModel.fromJson(
              json['comparisonWithLastMonth'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WeeklyBreakdownModel extends WeeklyBreakdown {
  const WeeklyBreakdownModel({
    required super.weekStart,
    required super.orders,
    required super.earnings,
  });

  factory WeeklyBreakdownModel.fromJson(Map<String, dynamic> json) {
    return WeeklyBreakdownModel(
      weekStart: json['weekStart'] as String? ?? '',
      orders: json['orders'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
    );
  }
}
