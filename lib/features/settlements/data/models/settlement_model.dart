import '../../domain/entities/settlement_entity.dart';

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.partnerId,
    required super.partnerName,
    required super.amount,
    required super.settlementType,
    required super.settlementTypeName,
    super.notes,
    super.receiptImageUrl,
    required super.whatsAppSent,
    required super.createdAt,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      settlementType: json['settlementType'] as int? ?? 0,
      settlementTypeName: json['settlementTypeName'] as String? ?? '',
      notes: json['notes'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      whatsAppSent: json['whatsAppSent'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
