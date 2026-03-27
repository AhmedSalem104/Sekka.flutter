import 'package:dio/dio.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/caller_id_model.dart';
import '../models/truecaller_model.dart';

class CallerIdRepository {
    CallerIdRepository(this._dio);
  final Dio _dio;

  /// GET /api/v1/caller-id/lookup/{phone}
  Future<ApiResult<CallerIdModel>> lookup(String phone) async {
    return ApiHelper.execute(
      () => _dio.get('/caller-id/lookup/$phone'),
      parser: (data) => CallerIdModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// POST /api/v1/caller-id
  Future<ApiResult<CallerIdModel>> createNote({
    required String phoneNumber,
    required int contactType,
    String? displayName,
    String? note,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        '/caller-id',
        data: {
          'phoneNumber': phoneNumber,
          'contactType': contactType,
          if (displayName != null) 'displayName': displayName,
          if (note != null) 'note': note,
        },
      ),
      parser: (data) => CallerIdModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /api/v1/caller-id/{id}
  Future<ApiResult<CallerIdModel>> updateNote(
    String id, {
    String? displayName,
    String? note,
  }) async {
    return ApiHelper.execute(
      () => _dio.put(
        '/caller-id/$id',
        data: {
          if (displayName != null) 'displayName': displayName,
          if (note != null) 'note': note,
        },
      ),
      parser: (data) => CallerIdModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// DELETE /api/v1/caller-id/{id}
  Future<ApiResult<bool>> deleteNote(String id) async {
    return ApiHelper.execute(
      () => _dio.delete('/caller-id/$id'),
      parser: (data) => data as bool,
    );
  }

  /// GET /api/v1/caller-id/truecaller-lookup/{phone}
  Future<ApiResult<TruecallerModel>> truecallerLookup(String phone) async {
    return ApiHelper.execute(
      () => _dio.get('/caller-id/truecaller-lookup/$phone'),
      parser: (data) =>
          TruecallerModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
