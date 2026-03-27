import 'package:equatable/equatable.dart';

class WalletSummaryEntity extends Equatable {
  const WalletSummaryEntity({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalCommissions,
    required this.totalSettlements,
    required this.netProfit,
    required this.transactionCount,
    required this.dateFrom,
    required this.dateTo,
  });

  final double totalIncome;
  final double totalExpenses;
  final double totalCommissions;
  final double totalSettlements;
  final double netProfit;
  final int transactionCount;
  final String dateFrom;
  final String dateTo;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        totalCommissions,
        totalSettlements,
        netProfit,
        transactionCount,
      ];
}
