import '../../domain/entities/cancellation_report_entity.dart';

class CancellationReportModel extends CancellationReportEntity {
  const CancellationReportModel({
    required super.reason,
    required super.count,
    required super.percentage,
  });

  factory CancellationReportModel.fromJson(Map<String, dynamic> json) {
    return CancellationReportModel(
      reason: json['reason'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'count': count,
        'percentage': percentage,
      };
}
