import '../../domain/entities/daily_stats_entity.dart';

class DailyStatsModel extends DailyStatsEntity {
  const DailyStatsModel({
    required super.date,
    required super.totalOrders,
    required super.successfulOrders,
    required super.failedOrders,
    required super.cancelledOrders,
    required super.earnings,
    required super.commissions,
    required super.expenses,
    required super.netProfit,
    required super.distanceKm,
    required super.timeWorkedMinutes,
    required super.successRate,
    required super.averageOrderValue,
    required super.averageDeliveryTimeMinutes,
    required super.tips,
    required super.peakHour,
    required super.peakHourOrders,
  });

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    return DailyStatsModel(
      date: json['date'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      successfulOrders: json['successfulOrders'] as int? ?? 0,
      failedOrders: json['failedOrders'] as int? ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      earnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      commissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      expenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      timeWorkedMinutes: json['timeWorkedMinutes'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
      averageDeliveryTimeMinutes:
          json['averageDeliveryTimeMinutes'] as int? ?? 0,
      tips: (json['cashCollected'] as num?)?.toDouble() ?? 0,
      peakHour: json['peakHour'] as int? ?? 0,
      peakHourOrders: json['peakHourOrders'] as int? ?? 0,
    );
  }
}
