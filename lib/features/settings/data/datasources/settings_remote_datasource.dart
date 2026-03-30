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

  /// PUT /settings/focus-mode
  /// API expects: { autoTrigger: bool, speedThreshold: int }
  Future<void> updateFocusMode(Map<String, dynamic> data) async {
    try {
      // Map from entity keys to API keys
      final apiData = <String, dynamic>{};
      if (data.containsKey('focusModeAutoTrigger')) {
        apiData['autoTrigger'] = data['focusModeAutoTrigger'];
      }
      if (data.containsKey('focusModeSpeedThreshold')) {
        apiData['speedThreshold'] = data['focusModeSpeedThreshold'];
      }

      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.settingsFocusMode,
        data: apiData,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /settings/quiet-hours
  /// API expects: { enabled: bool, startTime: "HH:mm:ss", endTime: "HH:mm:ss" }
  Future<void> updateQuietHours(Map<String, dynamic> data) async {
    try {
      final start = data['quietHoursStart'] as String?;
      final end = data['quietHoursEnd'] as String?;
      final enabled = start != null && end != null;

      final apiData = {
        'enabled': enabled,
        'startTime': start != null ? '$start:00' : '00:00:00',
        'endTime': end != null ? '$end:00' : '23:59:59',
      };

      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.settingsQuietHours,
        data: apiData,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /settings/notifications
  /// API expects same key names as entity
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

  /// POST /settings/home-location
  /// API expects: { homeLatitude: double, homeLongitude: double, homeAddress: string }
  Future<void> setHomeLocation(Map<String, dynamic> data) async {
    try {
      final apiData = {
        'homeLatitude': data['latitude'],
        'homeLongitude': data['longitude'],
        'homeAddress': data['address'],
      };

      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.settingsHomeLocation,
        data: apiData,
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
