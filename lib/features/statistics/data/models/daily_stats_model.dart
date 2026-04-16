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
    super.bestRegion,
    super.bestTimeSlot,
    super.postponedOrders,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'totalOrders': totalOrders,
        'successfulOrders': successfulOrders,
        'failedOrders': failedOrders,
        'cancelledOrders': cancelledOrders,
        'totalEarnings': earnings,
        'totalCommissions': commissions,
        'totalExpenses': expenses,
        'netProfit': netProfit,
        'totalDistanceKm': distanceKm,
        'timeWorkedMinutes': timeWorkedMinutes,
        'successRate': successRate,
        'averageOrderValue': averageOrderValue,
        'averageDeliveryTimeMinutes': averageDeliveryTimeMinutes,
        'cashCollected': tips,
        'peakHour': peakHour,
        'peakHourOrders': peakHourOrders,
      };

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    final totalOrders = json['totalOrders'] as int? ?? 0;
    final successfulOrders = json['successfulOrders'] as int? ?? 0;
    final earnings = (json['totalEarnings'] as num?)?.toDouble() ?? 0;
    final serverRate = (json['successRate'] as num?)?.toDouble();
    final computedRate = totalOrders > 0
        ? (successfulOrders / totalOrders) * 100
        : 0.0;
    final avgOrder = (json['averageOrderValue'] as num?)?.toDouble() ??
        (successfulOrders > 0 ? earnings / successfulOrders : 0);

    return DailyStatsModel(
      date: json['date'] as String? ?? '',
      totalOrders: totalOrders,
      successfulOrders: successfulOrders,
      failedOrders: json['failedOrders'] as int? ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      earnings: earnings,
      commissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      expenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      timeWorkedMinutes: json['timeWorkedMinutes'] as int? ?? 0,
      successRate: serverRate ?? computedRate,
      averageOrderValue: avgOrder,
      averageDeliveryTimeMinutes:
          json['averageDeliveryTimeMinutes'] as int? ?? 0,
      tips: (json['cashCollected'] as num?)?.toDouble() ?? 0,
      peakHour: json['peakHour'] as int? ?? 0,
      peakHourOrders: json['peakHourOrders'] as int? ?? 0,
      bestRegion: json['bestRegion'] as String?,
      bestTimeSlot: json['bestTimeSlot'] as String?,
      postponedOrders: json['postponedOrders'] as int? ?? 0,
    );
  }
}
