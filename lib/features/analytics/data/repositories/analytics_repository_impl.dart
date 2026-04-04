import '../../domain/entities/cancellation_report_entity.dart';
import '../../domain/entities/customer_profitability_entity.dart';
import '../../domain/entities/profitability_trends_entity.dart';
import '../../domain/entities/region_analysis_entity.dart';
import '../../domain/entities/source_breakdown_entity.dart';
import '../../domain/entities/time_analysis_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final AnalyticsRemoteDataSource _remote;

  @override
  Future<List<SourceBreakdownEntity>> getSourceBreakdown() =>
      _remote.getSourceBreakdown();

  @override
  Future<List<CustomerProfitabilityEntity>> getCustomerProfitability() =>
      _remote.getCustomerProfitability();

  @override
  Future<List<RegionAnalysisEntity>> getRegionAnalysis() =>
      _remote.getRegionAnalysis();

  @override
  Future<List<TimeAnalysisEntity>> getTimeAnalysis() =>
      _remote.getTimeAnalysis();

  @override
  Future<List<CancellationReportEntity>> getCancellationReport() =>
      _remote.getCancellationReport();

  @override
  Future<List<ProfitabilityTrendsEntity>> getProfitabilityTrends() =>
      _remote.getProfitabilityTrends();
}
