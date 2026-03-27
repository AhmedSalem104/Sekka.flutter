import '../../domain/entities/wallet_summary_entity.dart';

class WalletSummaryModel extends WalletSummaryEntity {
  const WalletSummaryModel({
    required super.totalIncome,
    required super.totalExpenses,
    required super.totalCommissions,
    required super.totalSettlements,
    required super.netProfit,
    required super.transactionCount,
    required super.dateFrom,
    required super.dateTo,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      totalSettlements: (json['totalSettlements'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      dateFrom: json['dateFrom'] as String? ?? '',
      dateTo: json['dateTo'] as String? ?? '',
    );
  }
}
