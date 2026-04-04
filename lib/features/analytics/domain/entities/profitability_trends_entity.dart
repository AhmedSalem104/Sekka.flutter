import 'package:equatable/equatable.dart';

class ProfitabilityTrendsEntity extends Equatable {
  const ProfitabilityTrendsEntity({
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.profitMargin,
  });

  final String period;
  final double revenue;
  final double expenses;
  final double netProfit;
  final double profitMargin;

  @override
  List<Object?> get props => [period, revenue, expenses, netProfit, profitMargin];
}
