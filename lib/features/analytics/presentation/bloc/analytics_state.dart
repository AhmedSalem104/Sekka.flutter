import 'package:equatable/equatable.dart';

import '../../domain/entities/cancellation_report_entity.dart';
import '../../domain/entities/customer_profitability_entity.dart';
import '../../domain/entities/profitability_trends_entity.dart';
import '../../domain/entities/region_analysis_entity.dart';
import '../../domain/entities/source_breakdown_entity.dart';
import '../../domain/entities/time_analysis_entity.dart';

sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

final class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded({
    required this.sourceBreakdown,
    required this.customerProfitability,
    required this.regionAnalysis,
    required this.timeAnalysis,
    required this.cancellationReport,
    required this.profitabilityTrends,
  });

  final List<SourceBreakdownEntity> sourceBreakdown;
  final List<CustomerProfitabilityEntity> customerProfitability;
  final List<RegionAnalysisEntity> regionAnalysis;
  final List<TimeAnalysisEntity> timeAnalysis;
  final List<CancellationReportEntity> cancellationReport;
  final List<ProfitabilityTrendsEntity> profitabilityTrends;

  bool get hasAnyData =>
      sourceBreakdown.isNotEmpty ||
      customerProfitability.isNotEmpty ||
      regionAnalysis.isNotEmpty ||
      timeAnalysis.isNotEmpty ||
      cancellationReport.isNotEmpty ||
      profitabilityTrends.isNotEmpty;

  @override
  List<Object?> get props => [
        sourceBreakdown,
        customerProfitability,
        regionAnalysis,
        timeAnalysis,
        cancellationReport,
        profitabilityTrends,
      ];
}

final class AnalyticsError extends AnalyticsState {
  const AnalyticsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
