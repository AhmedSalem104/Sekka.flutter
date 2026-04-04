import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/help_request_model.dart';
import '../models/nearby_driver_model.dart';

class ColleagueRadarRepository {
  const ColleagueRadarRepository(this._dio);

  final Dio _dio;

  /// GET /colleague-radar/nearby
  Future<ApiResult<List<NearbyDriverModel>>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) =>
      ApiHelper.execute(
        () => _dio.get(
          ApiConstants.colleagueRadarNearby,
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radiusKm': radiusKm,
          },
        ),
        parser: (data) => (data as List<dynamic>)
            .map((e) =>
                NearbyDriverModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// GET /colleague-radar/help-requests/nearby
  Future<ApiResult<List<HelpRequestModel>>> getNearbyHelpRequests({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) =>
      ApiHelper.execute(
        () => _dio.get(
          ApiConstants.colleagueRadarHelpRequestsNearby,
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radiusKm': radiusKm,
          },
        ),
        parser: (data) => (data as List<dynamic>)
            .map((e) =>
                HelpRequestModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// GET /colleague-radar/help-requests/my
  Future<ApiResult<List<HelpRequestModel>>> getMyHelpRequests() =>
      ApiHelper.execute(
        () => _dio.get(ApiConstants.colleagueRadarMyRequests),
        parser: (data) => (data as List<dynamic>)
            .map((e) =>
                HelpRequestModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// POST /colleague-radar/help-requests
  Future<ApiResult<HelpRequestModel>> createHelpRequest({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required String helpType,
  }) =>
      ApiHelper.execute(
        () => _dio.post(
          ApiConstants.colleagueRadarHelpRequests,
          data: {
            'title': title,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            'helpType': helpType,
          },
        ),
        parser: (data) =>
            HelpRequestModel.fromJson(data as Map<String, dynamic>),
      );

  /// POST /colleague-radar/help-requests/{id}/respond
  Future<ApiResult<HelpRequestModel>> respondToRequest(String requestId) =>
      ApiHelper.execute(
        () => _dio.post(ApiConstants.colleagueRadarRespond(requestId)),
        parser: (data) =>
            HelpRequestModel.fromJson(data as Map<String, dynamic>),
      );

  /// POST /colleague-radar/help-requests/{id}/resolve
  Future<ApiResult<void>> resolveRequest(String requestId) =>
      ApiHelper.execute(
        () => _dio.post(ApiConstants.colleagueRadarResolve(requestId)),
        parser: (_) {},
      );
}
