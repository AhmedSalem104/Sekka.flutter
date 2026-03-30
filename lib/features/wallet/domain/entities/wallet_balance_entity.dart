import 'package:equatable/equatable.dart';

class WalletBalanceEntity extends Equatable {
  const WalletBalanceEntity({
    required this.driverId,
    required this.balance,
    required this.cashOnHand,
    required this.pendingSettlements,
    required this.lastUpdated,
  });

  final String driverId;
  final double balance;
  final double cashOnHand;
  final double pendingSettlements;
  final DateTime lastUpdated;

  /// Alias used by UI (BalanceCard references totalBalance).
  double get totalBalance => balance;

  @override
  List<Object?> get props => [
        driverId,
        balance,
        cashOnHand,
        pendingSettlements,
        lastUpdated,
      ];
}
