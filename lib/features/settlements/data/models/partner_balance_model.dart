import '../../domain/entities/partner_balance_entity.dart';

class PartnerBalanceModel extends PartnerBalanceEntity {
  const PartnerBalanceModel({
    required super.partnerId,
    required super.partnerName,
    required super.totalCollected,
    required super.totalSettled,
    required super.pendingBalance,
    required super.pendingOrderCount,
  });

  Map<String, dynamic> toJson() => {
        'partnerId': partnerId,
        'partnerName': partnerName,
        'totalCollected': totalCollected,
        'totalSettled': totalSettled,
        'pendingBalance': pendingBalance,
        'pendingOrderCount': pendingOrderCount,
      };

  factory PartnerBalanceModel.fromJson(Map<String, dynamic> json) {
    return PartnerBalanceModel(
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String? ?? '',
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0,
      totalSettled: (json['totalSettled'] as num?)?.toDouble() ?? 0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0,
      pendingOrderCount: json['pendingOrderCount'] as int? ?? 0,
    );
  }
}
