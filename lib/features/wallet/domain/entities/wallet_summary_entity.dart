import 'package:equatable/equatable.dart';

class WalletSummaryEntity extends Equatable {
  const WalletSummaryEntity({
    required this.totalEarnings,
    required this.totalExpenses,
    required this.totalSettlements,
    required this.netBalance,
    required this.transactionCount,
  });

  final double totalEarnings;
  final double totalExpenses;
  final double totalSettlements;
  final double netBalance;
  final int transactionCount;

  /// Alias used by UI widgets.
  double get totalIncome => totalEarnings;

  @override
  List<Object?> get props => [
        totalEarnings,
        totalExpenses,
        totalSettlements,
        netBalance,
        transactionCount,
      ];
}
