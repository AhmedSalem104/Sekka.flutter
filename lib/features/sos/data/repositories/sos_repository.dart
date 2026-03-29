import 'package:dio/dio.dart';
import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../models/sos_model.dart';

class SosRepository {
    SosRepository(this._dio);
  final Dio _dio;

  /// POST /sos/activate
  Future<ApiResult<SosModel>> activate({
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(ApiConstants.sosActivate, data: {
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null) 'notes': notes,
      }),
      parser: (data) => SosModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// POST /sos/{id}/dismiss
  Future<ApiResult<bool>> dismiss(String id) async {
    return ApiHelper.execute(
      () => _dio.post(ApiConstants.sosDismiss(id), data: {}),
      parser: (data) => data == true,
    );
  }

  /// POST /sos/{id}/resolve
  Future<ApiResult<bool>> resolve(
    String id, {
    String? resolution,
    required bool wasFalseAlarm,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(ApiConstants.sosResolve(id), data: {
        'resolution': resolution,
        'wasFalseAlarm': wasFalseAlarm,
      }),
      parser: (data) => data == true,
    );
  }

  /// GET /sos/history?page=&pageSize=
  Future<ApiResult<PagedData<SosModel>>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.sosHistory,
        queryParameters: {'page': page, 'pageSize': pageSize},
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        SosModel.fromJson,
      ),
    );
  }
}
