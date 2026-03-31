import '../../domain/entities/wallet_summary_entity.dart';

class WalletSummaryModel extends WalletSummaryEntity {
  const WalletSummaryModel({
    required super.totalEarnings,
    required super.totalExpenses,
    required super.totalSettlements,
    required super.netBalance,
    required super.transactionCount,
  });

  Map<String, dynamic> toJson() => {
        'totalEarnings': totalEarnings,
        'totalExpenses': totalExpenses,
        'totalSettlements': totalSettlements,
        'netBalance': netBalance,
        'transactionCount': transactionCount,
      };

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      totalSettlements: (json['totalSettlements'] as num?)?.toDouble() ?? 0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }
}
