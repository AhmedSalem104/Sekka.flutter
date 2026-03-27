import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/api_result.dart';
import '../models/sos_model.dart';

class SosRepository {
  final _dio = ApiClient.instance.dio;

  /// POST /sos/activate
  Future<ApiResult<SosModel>> activate({
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    return ApiHelper.execute(
      () => _dio.post('/api/v1/sos/activate', data: {
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
      () => _dio.post('/api/v1/sos/$id/dismiss'),
      parser: (data) => data as bool,
    );
  }

  /// POST /sos/{id}/resolve
  Future<ApiResult<bool>> resolve(
    String id, {
    String? resolution,
    required bool wasFalseAlarm,
  }) async {
    return ApiHelper.execute(
      () => _dio.post('/api/v1/sos/$id/resolve', data: {
        'resolution': resolution,
        'wasFalseAlarm': wasFalseAlarm,
      }),
      parser: (data) => data as bool,
    );
  }

  /// GET /sos/history?page=&pageSize=
  Future<ApiResult<PagedData<SosModel>>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/api/v1/sos/history',
        queryParameters: {'page': page, 'pageSize': pageSize},
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        SosModel.fromJson,
      ),
    );
  }
}
