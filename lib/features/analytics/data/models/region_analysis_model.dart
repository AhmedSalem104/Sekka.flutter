import '../../domain/entities/region_analysis_entity.dart';

class RegionAnalysisModel extends RegionAnalysisEntity {
  const RegionAnalysisModel({
    required super.region,
    required super.totalOrders,
    required super.totalRevenue,
    required super.averageDeliveryTime,
    required super.successRate,
  });

  factory RegionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return RegionAnalysisModel(
      region: json['region'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      averageDeliveryTime:
          (json['averageDeliveryTime'] as num?)?.toDouble() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'region': region,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'averageDeliveryTime': averageDeliveryTime,
        'successRate': successRate,
      };
}
