import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/settings_model.dart';

class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<SettingsModel> getSettings() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.settings);
      final apiResponse = ApiResponse<SettingsModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            SettingsModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SettingsModel> updateSettings(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.settings,
        data: updates,
      );
      final apiResponse = ApiResponse<SettingsModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            SettingsModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateFocusMode(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.settingsFocusMode,
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

  Future<void> updateQuietHours(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.settingsQuietHours,
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

  Future<void> updateNotifications(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.settingsNotifications,
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

  Future<void> setHomeLocation(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.settingsHomeLocation,
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
