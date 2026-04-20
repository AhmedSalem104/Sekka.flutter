import '../../../../shared/utils/safe_parse.dart';
import '../../domain/entities/settlement_entity.dart';

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.driverId,
    required super.partnerId,
    super.partnerName,
    required super.amount,
    required super.settlementType,
    required super.orderCount,
    super.notes,
    super.receiptImageUrl,
    required super.whatsAppSent,
    required super.settledAt,
    required super.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'driverId': driverId,
        'partnerId': partnerId,
        'partnerName': partnerName,
        'amount': amount,
        'settlementType': settlementType,
        'orderCount': orderCount,
        'notes': notes,
        'receiptImageUrl': receiptImageUrl,
        'whatsAppSent': whatsAppSent,
        'settledAt': settledAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return SettlementModel(
      id: json['id'] as String,
      driverId: json['driverId'] as String? ?? '',
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      settlementType: safeInt(json['settlementType'], 0),
      orderCount: safeInt(json['orderCount'], 0),
      notes: json['notes'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      whatsAppSent: json['whatsAppSent'] as bool? ?? false,
      settledAt: DateTime.parse(json['settledAt'] as String? ?? now),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? now),
    );
  }
}
