import '../../domain/entities/profitability_trends_entity.dart';

class ProfitabilityTrendsModel extends ProfitabilityTrendsEntity {
  const ProfitabilityTrendsModel({
    required super.period,
    required super.revenue,
    required super.expenses,
    required super.netProfit,
    required super.profitMargin,
  });

  factory ProfitabilityTrendsModel.fromJson(Map<String, dynamic> json) {
    return ProfitabilityTrendsModel(
      period: json['period'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'revenue': revenue,
        'expenses': expenses,
        'netProfit': netProfit,
        'profitMargin': profitMargin,
      };
}
