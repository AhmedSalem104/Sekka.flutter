import 'package:equatable/equatable.dart';

class WalletBalanceEntity extends Equatable {
  const WalletBalanceEntity({
    required this.cashOnHand,
    required this.cashAlertThreshold,
    required this.cashAlertPercentage,
    required this.todayCollected,
    required this.todayCommissions,
    required this.pendingSettlements,
    required this.totalBalance,
    required this.availableBalance,
    required this.lastUpdatedAt,
  });

  final double cashOnHand;
  final double cashAlertThreshold;
  final double cashAlertPercentage;
  final double todayCollected;
  final double todayCommissions;
  final double pendingSettlements;
  final double totalBalance;
  final double availableBalance;
  final DateTime lastUpdatedAt;

  @override
  List<Object?> get props => [
        cashOnHand,
        cashAlertThreshold,
        cashAlertPercentage,
        todayCollected,
        todayCommissions,
        pendingSettlements,
        totalBalance,
        availableBalance,
        lastUpdatedAt,
      ];
}
