import 'package:dio/dio.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/pickup_point_model.dart';

class PickupPointRepository {
    PickupPointRepository(this._dio);
  final Dio _dio;

  /// POST /api/v1/pickup-points
  Future<ApiResult<PickupPointModel>> createPickupPoint({
    required String partnerId,
    required String name,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        '/pickup-points',
        data: {
          'partnerId': partnerId,
          'name': name,
          'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      ),
      parser: (data) =>
          PickupPointModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /api/v1/pickup-points/{id}
  Future<ApiResult<PickupPointModel>> updatePickupPoint(
    String id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    return ApiHelper.execute(
      () => _dio.put(
        '/pickup-points/$id',
        data: {
          if (name != null) 'name': name,
          if (address != null) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      ),
      parser: (data) =>
          PickupPointModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// DELETE /api/v1/pickup-points/{id}
  Future<ApiResult<bool>> deletePickupPoint(String id) async {
    return ApiHelper.execute(
      () => _dio.delete('/pickup-points/$id'),
      parser: (data) => data as bool,
    );
  }

  /// POST /api/v1/pickup-points/{id}/rate
  Future<ApiResult<bool>> ratePickupPoint(
    String id, {
    required int rating,
    int? waitingMinutes,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        '/pickup-points/$id/rate',
        data: {
          'rating': rating,
          if (waitingMinutes != null) 'waitingMinutes': waitingMinutes,
        },
      ),
      parser: (data) => data as bool,
    );
  }
}
