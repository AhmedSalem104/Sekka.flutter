import '../../domain/entities/cash_status_entity.dart';

class CashStatusModel extends CashStatusEntity {
  const CashStatusModel({
    required super.cashOnHand,
    required super.threshold,
    required super.percentage,
    required super.alertLevel,
    required super.suggestedAction,
  });

  factory CashStatusModel.fromJson(Map<String, dynamic> json) {
    return CashStatusModel(
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble() ?? 0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      alertLevel: json['alertLevel'] as String? ?? 'safe',
      suggestedAction: json['suggestedAction'] as String? ?? '',
    );
  }
}
