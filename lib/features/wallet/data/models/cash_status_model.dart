import '../../domain/entities/cash_status_entity.dart';

class CashStatusModel extends CashStatusEntity {
  const CashStatusModel({
    required super.driverId,
    required super.cashOnHand,
    required super.cashAlertThreshold,
    required super.isOverThreshold,
    super.lastSettlementAt,
    required super.hoursSinceLastSettlement,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'cashOnHand': cashOnHand,
        'cashAlertThreshold': cashAlertThreshold,
        'isOverThreshold': isOverThreshold,
        'lastSettlementAt': lastSettlementAt?.toIso8601String(),
        'hoursSinceLastSettlement': hoursSinceLastSettlement,
      };

  factory CashStatusModel.fromJson(Map<String, dynamic> json) {
    return CashStatusModel(
      driverId: json['driverId'] as String? ?? '',
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble() ?? 0,
      cashAlertThreshold:
          (json['cashAlertThreshold'] as num?)?.toDouble() ?? 0,
      isOverThreshold: json['isOverThreshold'] as bool? ?? false,
      lastSettlementAt: json['lastSettlementAt'] != null
          ? DateTime.parse(json['lastSettlementAt'] as String)
          : null,
      hoursSinceLastSettlement:
          json['hoursSinceLastSettlement'] as int? ?? 0,
    );
  }
}
