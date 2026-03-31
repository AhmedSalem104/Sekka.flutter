import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/sync_models.dart';

class SyncRemoteDataSource {
  SyncRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  /// GET /sync/status
  Future<SyncStatusModel> getStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.syncStatus,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return SyncStatusModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /sync/push
  Future<SyncPushResult> push({Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.syncPush,
        data: data ?? <String, dynamic>{},
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return SyncPushResult.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /sync/pull
  Future<SyncPullResult> pull({String? since}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.syncPull,
        queryParameters: {
          if (since != null) 'since': since,
        },
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return SyncPullResult.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /sync/resolve-conflict
  Future<void> resolveConflict(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.syncResolveConflict,
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
