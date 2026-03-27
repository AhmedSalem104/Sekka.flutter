import '../../domain/entities/daily_settlement_summary_entity.dart';

class DailySettlementSummaryModel extends DailySettlementSummaryEntity {
  const DailySettlementSummaryModel({
    required super.date,
    required super.totalSettled,
    required super.settlementCount,
    required super.byType,
    super.topPartner,
  });

  factory DailySettlementSummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySettlementSummaryModel(
      date: json['date'] as String? ?? '',
      totalSettled: (json['totalSettled'] as num?)?.toDouble() ?? 0,
      settlementCount: json['settlementCount'] as int? ?? 0,
      byType: (json['byType'] as List?)
              ?.map((e) => SettlementByTypeModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      topPartner: json['topPartner'] != null
          ? TopPartnerModel.fromJson(
              json['topPartner'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SettlementByTypeModel extends SettlementByType {
  const SettlementByTypeModel({
    required super.type,
    required super.typeName,
    required super.amount,
    required super.count,
  });

  factory SettlementByTypeModel.fromJson(Map<String, dynamic> json) {
    return SettlementByTypeModel(
      type: json['type'] as int? ?? 0,
      typeName: json['typeName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class TopPartnerModel extends TopPartner {
  const TopPartnerModel({
    required super.partnerId,
    required super.partnerName,
    required super.amount,
  });

  factory TopPartnerModel.fromJson(Map<String, dynamic> json) {
    return TopPartnerModel(
      partnerId: json['partnerId'] as String? ?? '',
      partnerName: json['partnerName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
