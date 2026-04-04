import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/consent_model.dart';

class PrivacyRemoteDataSource {
  PrivacyRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<List<ConsentModel>> getConsents() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.privacyConsents,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ConsentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ConsentModel> updateConsent(String type, bool isGranted) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.privacyConsent(type),
        data: {'isGranted': isGranted},
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return ConsentModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DataRequestModel> requestDataExport() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.privacyExportData,
        data: {},
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return DataRequestModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DataRequestModel> requestDataDeletion(
    String requestType,
    String? reason,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.privacyDeleteData,
        data: {
          'requestType': requestType,
          if (reason != null) 'reason': reason,
        },
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return DataRequestModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DataRequestModel> getDeleteStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.privacyDeleteDataStatus,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return DataRequestModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
