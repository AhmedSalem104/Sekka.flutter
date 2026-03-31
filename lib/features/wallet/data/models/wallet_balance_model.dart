import '../../domain/entities/wallet_balance_entity.dart';

class WalletBalanceModel extends WalletBalanceEntity {
  const WalletBalanceModel({
    required super.driverId,
    required super.balance,
    required super.cashOnHand,
    required super.pendingSettlements,
    required super.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'balance': balance,
        'cashOnHand': cashOnHand,
        'pendingSettlements': pendingSettlements,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      driverId: json['driverId'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble() ?? 0,
      pendingSettlements:
          (json['pendingSettlements'] as num?)?.toDouble() ?? 0,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
