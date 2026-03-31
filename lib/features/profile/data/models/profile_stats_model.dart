import '../../domain/entities/profile_stats_entity.dart';

class ProfileStatsModel extends ProfileStatsEntity {
  const ProfileStatsModel({
    required super.totalOrders,
    required super.totalDelivered,
    required super.totalFailed,
    required super.totalCancelled,
    required super.successRate,
    required super.averageRating,
    required super.totalEarnings,
    required super.totalCommissions,
    required super.averageDeliveryTimeMinutes,
    required super.bestDay,
    required super.bestDayOrders,
  });

  Map<String, dynamic> toJson() => {
        'totalOrders': totalOrders,
        'totalDelivered': totalDelivered,
        'totalFailed': totalFailed,
        'totalCancelled': totalCancelled,
        'successRate': successRate,
        'averageRating': averageRating,
        'totalEarnings': totalEarnings,
        'totalCommissions': totalCommissions,
        'averageDeliveryTimeMinutes': averageDeliveryTimeMinutes,
        'bestDay': bestDay,
        'bestDayOrders': bestDayOrders,
      };

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalDelivered: json['totalDelivered'] as int? ?? 0,
      totalFailed: json['totalFailed'] as int? ?? 0,
      totalCancelled: json['totalCancelled'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      averageDeliveryTimeMinutes:
          (json['averageDeliveryTimeMinutes'] as num?)?.toDouble() ?? 0,
      bestDay: json['bestDay'] as String?,
      bestDayOrders: json['bestDayOrders'] as int? ?? 0,
    );
  }
}
