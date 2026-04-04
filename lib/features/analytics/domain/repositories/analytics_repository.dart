import '../entities/cancellation_report_entity.dart';
import '../entities/customer_profitability_entity.dart';
import '../entities/profitability_trends_entity.dart';
import '../entities/region_analysis_entity.dart';
import '../entities/source_breakdown_entity.dart';
import '../entities/time_analysis_entity.dart';

abstract class AnalyticsRepository {
  Future<List<SourceBreakdownEntity>> getSourceBreakdown();
  Future<List<CustomerProfitabilityEntity>> getCustomerProfitability();
  Future<List<RegionAnalysisEntity>> getRegionAnalysis();
  Future<List<TimeAnalysisEntity>> getTimeAnalysis();
  Future<List<CancellationReportEntity>> getCancellationReport();
  Future<List<ProfitabilityTrendsEntity>> getProfitabilityTrends();
}
