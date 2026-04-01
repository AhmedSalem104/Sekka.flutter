import 'package:dio/dio.dart';
import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/customer_behavior_model.dart';
import '../models/customer_insights_profile_model.dart';
import '../models/customer_recommendation_model.dart';

class CustomerInsightsRepository {
  CustomerInsightsRepository(this._dio);
  final Dio _dio;

  /// GET /api/v1/customer-insights/{customerId}/profile
  Future<ApiResult<CustomerInsightsProfileModel>> getProfile(
    String customerId,
  ) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerInsightsProfile(customerId)),
      parser: (data) => CustomerInsightsProfileModel.fromJson(
        data as Map<String, dynamic>,
      ),
    );
  }

  /// GET /api/v1/customer-insights/{customerId}/interests
  Future<ApiResult<List<Map<String, dynamic>>>> getInterests(
    String customerId,
  ) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerInsightsInterests(customerId)),
      parser: (data) => (data as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  /// GET /api/v1/customer-insights/{customerId}/recommendations
  Future<ApiResult<List<CustomerRecommendationModel>>> getRecommendations(
    String customerId,
  ) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerInsightsRecommendations(customerId)),
      parser: (data) => (data as List<dynamic>?)
              ?.map((e) => CustomerRecommendationModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
    );
  }

  /// PUT /api/v1/customer-insights/recommendations/{id}/read
  Future<ApiResult<bool>> markRecommendationRead(String recommendationId) {
    return ApiHelper.execute(
      () => _dio.put(
        ApiConstants.customerInsightsRecommendationRead(recommendationId),
        data: {},
      ),
      parser: (data) => data == true,
    );
  }

  /// PUT /api/v1/customer-insights/recommendations/{id}/dismiss
  Future<ApiResult<bool>> dismissRecommendation(String recommendationId) {
    return ApiHelper.execute(
      () => _dio.put(
        ApiConstants.customerInsightsRecommendationDismiss(recommendationId),
        data: {},
      ),
      parser: (data) => data == true,
    );
  }

  /// PUT /api/v1/customer-insights/recommendations/{id}/act
  Future<ApiResult<bool>> actOnRecommendation(String recommendationId) {
    return ApiHelper.execute(
      () => _dio.put(
        ApiConstants.customerInsightsRecommendationAct(recommendationId),
        data: {},
      ),
      parser: (data) => data == true,
    );
  }

  /// GET /api/v1/customer-insights/{customerId}/behavior
  Future<ApiResult<CustomerBehaviorModel>> getBehavior(
    String customerId,
  ) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerInsightsBehavior(customerId)),
      parser: (data) =>
          CustomerBehaviorModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /api/v1/customer-insights/top-interests
  Future<ApiResult<List<Map<String, dynamic>>>> getTopInterests({
    int? limit,
    String? dateFrom,
    String? dateTo,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.customerInsightsTopInterests,
        queryParameters: {
          if (limit != null) 'Limit': limit,
          if (dateFrom != null) 'DateFrom': dateFrom,
          if (dateTo != null) 'DateTo': dateTo,
        },
      ),
      parser: (data) => (data as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  /// GET /api/v1/customer-insights/segments
  Future<ApiResult<List<Map<String, dynamic>>>> getSegments() async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerInsightsSegments),
      parser: (data) => (data as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  /// GET /api/v1/customer-insights/segments/{segmentId}/customers
  Future<ApiResult<List<Map<String, dynamic>>>> getSegmentCustomers(
    String segmentId,
  ) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.customerInsightsSegmentCustomers(segmentId),
      ),
      parser: (data) => (data as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
