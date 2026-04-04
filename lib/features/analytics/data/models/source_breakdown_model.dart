import '../../domain/entities/source_breakdown_entity.dart';

class SourceBreakdownModel extends SourceBreakdownEntity {
  const SourceBreakdownModel({
    required super.source,
    required super.count,
    required super.percentage,
  });

  factory SourceBreakdownModel.fromJson(Map<String, dynamic> json) {
    return SourceBreakdownModel(
      source: json['source'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        'count': count,
        'percentage': percentage,
      };
}
