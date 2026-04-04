import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/shift_model.dart';
import '../models/shift_summary_model.dart';

class ShiftRemoteDataSource {
  ShiftRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<ShiftModel> startShift({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.shiftStart,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final apiResponse = ApiResponse<ShiftModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ShiftModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ShiftModel> endShift() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.shiftEnd,
        data: {},
      );
      final apiResponse = ApiResponse<ShiftModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ShiftModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ShiftModel?> getCurrentShift() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.shiftCurrent,
      );
      final json = response.data!;
      if (json['isSuccess'] != true || json['data'] == null) {
        return null;
      }
      return ShiftModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      // 404 means no active shift — not an error
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  Future<ShiftSummaryModel> getSummary({
    String? from,
    String? to,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.shiftSummary,
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      final apiResponse = ApiResponse<ShiftSummaryModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ShiftSummaryModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
