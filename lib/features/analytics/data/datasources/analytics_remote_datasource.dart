import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/cancellation_report_model.dart';
import '../models/customer_profitability_model.dart';
import '../models/profitability_trends_model.dart';
import '../models/region_analysis_model.dart';
import '../models/source_breakdown_model.dart';
import '../models/time_analysis_model.dart';

class AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<List<T>> _fetchList<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      final data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<SourceBreakdownModel>> getSourceBreakdown() =>
      _fetchList(
        ApiConstants.analyticsSourceBreakdown,
        SourceBreakdownModel.fromJson,
      );

  Future<List<CustomerProfitabilityModel>> getCustomerProfitability() =>
      _fetchList(
        ApiConstants.analyticsCustomerProfitability,
        CustomerProfitabilityModel.fromJson,
      );

  Future<List<RegionAnalysisModel>> getRegionAnalysis() =>
      _fetchList(
        ApiConstants.analyticsRegionAnalysis,
        RegionAnalysisModel.fromJson,
      );

  Future<List<TimeAnalysisModel>> getTimeAnalysis() =>
      _fetchList(
        ApiConstants.analyticsTimeAnalysis,
        TimeAnalysisModel.fromJson,
      );

  Future<List<CancellationReportModel>> getCancellationReport() =>
      _fetchList(
        ApiConstants.analyticsCancellationReport,
        CancellationReportModel.fromJson,
      );

  Future<List<ProfitabilityTrendsModel>> getProfitabilityTrends() =>
      _fetchList(
        ApiConstants.analyticsProfitabilityTrends,
        ProfitabilityTrendsModel.fromJson,
      );
}
