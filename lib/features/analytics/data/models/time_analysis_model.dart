import '../../domain/entities/time_analysis_entity.dart';

class TimeAnalysisModel extends TimeAnalysisEntity {
  const TimeAnalysisModel({
    required super.hour,
    required super.dayOfWeek,
    required super.totalOrders,
    required super.averageEarnings,
  });

  factory TimeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TimeAnalysisModel(
      hour: json['hour'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      averageEarnings: (json['averageEarnings'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'dayOfWeek': dayOfWeek,
        'totalOrders': totalOrders,
        'averageEarnings': averageEarnings,
      };
}
