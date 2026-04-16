import '../../domain/entities/heatmap_stats_entity.dart';

class HeatmapCellModel extends HeatmapCellEntity {
  const HeatmapCellModel({
    required super.dayOfWeek,
    required super.hour,
    required super.orders,
    required super.earnings,
  });

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'hour': hour,
        'orders': orders,
        'earnings': earnings,
      };

  factory HeatmapCellModel.fromJson(Map<String, dynamic> json) {
    return HeatmapCellModel(
      dayOfWeek: json['dayOfWeek'] as int? ?? 0,
      hour: json['hour'] as int? ?? 0,
      orders: json['orders'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
    );
  }
}
