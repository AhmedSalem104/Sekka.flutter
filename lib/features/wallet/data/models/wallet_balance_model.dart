import '../../domain/entities/wallet_balance_entity.dart';

class WalletBalanceModel extends WalletBalanceEntity {
  const WalletBalanceModel({
    required super.cashOnHand,
    required super.cashAlertThreshold,
    required super.cashAlertPercentage,
    required super.todayCollected,
    required super.todayCommissions,
    required super.pendingSettlements,
    required super.totalBalance,
    required super.availableBalance,
    required super.lastUpdatedAt,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble() ?? 0,
      cashAlertThreshold: (json['cashAlertThreshold'] as num?)?.toDouble() ?? 0,
      cashAlertPercentage:
          (json['cashAlertPercentage'] as num?)?.toDouble() ?? 0,
      todayCollected: (json['todayCollected'] as num?)?.toDouble() ?? 0,
      todayCommissions: (json['todayCommissions'] as num?)?.toDouble() ?? 0,
      pendingSettlements:
          (json['pendingSettlements'] as num?)?.toDouble() ?? 0,
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      lastUpdatedAt: DateTime.parse(
        json['lastUpdatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
