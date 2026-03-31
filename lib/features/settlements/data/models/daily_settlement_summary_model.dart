import '../../domain/entities/daily_settlement_summary_entity.dart';

class DailySettlementSummaryModel extends DailySettlementSummaryEntity {
  const DailySettlementSummaryModel({
    required super.date,
    required super.totalCollected,
    required super.totalSettled,
    required super.remainingBalance,
    required super.settlementCount,
    required super.pendingPartners,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'totalCollected': totalCollected,
        'totalSettled': totalSettled,
        'remainingBalance': remainingBalance,
        'settlementCount': settlementCount,
        'pendingPartners': pendingPartners,
      };

  factory DailySettlementSummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySettlementSummaryModel(
      date: json['date'] as String? ?? '',
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0,
      totalSettled: (json['totalSettled'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0,
      settlementCount: json['settlementCount'] as int? ?? 0,
      pendingPartners: json['pendingPartners'] as int? ?? 0,
    );
  }
}
