import '../../domain/entities/weekly_stats_entity.dart';

class WeeklyStatsModel extends WeeklyStatsEntity {
  const WeeklyStatsModel({
    required super.weekStart,
    required super.weekEnd,
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
    required super.dailyBreakdown,
    super.bestDay,
    super.worstDay,
    super.comparisonWithLastWeek,
  });

  Map<String, dynamic> toJson() => {
        'weekStart': weekStart,
        'weekEnd': weekEnd,
        'totalOrders': totalOrders,
        'successfulOrders': successfulOrders,
        'totalEarnings': earnings,
        'totalCommissions': commissions,
        'totalExpenses': expenses,
        'netProfit': netProfit,
        'totalDistanceKm': distanceKm,
        'timeWorkedMinutes': timeWorkedMinutes,
        'successRate': successRate,
        'averageOrderValue': averageOrderValue,
        'dailyBreakdown': dailyBreakdown
            .map((d) => {'date': d.date, 'orders': d.orders, 'earnings': d.earnings})
            .toList(),
        'bestDay': bestDay,
        'worstDay': worstDay,
        'comparisonWithLastWeek': comparisonWithLastWeek != null
            ? {
                'ordersChange': comparisonWithLastWeek!.ordersChange,
                'earningsChange': comparisonWithLastWeek!.earningsChange,
                'successRateChange': comparisonWithLastWeek!.successRateChange,
              }
            : null,
      };

  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStatsModel(
      weekStart: json['weekStart'] as String? ?? '',
      weekEnd: json['weekEnd'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      successfulOrders: json['successfulOrders'] as int? ?? 0,
      earnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      commissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      expenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      timeWorkedMinutes: json['timeWorkedMinutes'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
      dailyBreakdown: (json['dailyBreakdown'] as List?)
              ?.map((e) => DailyBreakdownModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      bestDay: json['bestDay'] as String?,
      worstDay: json['worstDay'] as String?,
      comparisonWithLastWeek: json['comparisonWithLastWeek'] != null
          ? StatsComparisonModel.fromJson(
              json['comparisonWithLastWeek'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DailyBreakdownModel extends DailyBreakdown {
  const DailyBreakdownModel({
    required super.date,
    required super.orders,
    required super.earnings,
  });

  factory DailyBreakdownModel.fromJson(Map<String, dynamic> json) {
    return DailyBreakdownModel(
      date: json['date'] as String? ?? '',
      orders: json['orders'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StatsComparisonModel extends StatsComparison {
  const StatsComparisonModel({
    required super.ordersChange,
    required super.earningsChange,
    required super.successRateChange,
  });

  factory StatsComparisonModel.fromJson(Map<String, dynamic> json) {
    return StatsComparisonModel(
      ordersChange: (json['ordersChange'] as num?)?.toDouble() ?? 0,
      earningsChange: (json['earningsChange'] as num?)?.toDouble() ?? 0,
      successRateChange: (json['successRateChange'] as num?)?.toDouble() ?? 0,
    );
  }
}
