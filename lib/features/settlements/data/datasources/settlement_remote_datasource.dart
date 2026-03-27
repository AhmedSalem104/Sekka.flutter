import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../../shared/network/paginated_response.dart';
import '../models/daily_settlement_summary_model.dart';
import '../models/settlement_model.dart';

class SettlementRemoteDataSource {
  SettlementRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<PaginatedResponse<SettlementModel>> getSettlements({
    int pageNumber = 1,
    int pageSize = 20,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.settlements,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
        },
      );
      final apiResponse =
          ApiResponse<PaginatedResponse<SettlementModel>>.fromJson(
        response.data!,
        fromJsonT: (data) => PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          fromJsonT: SettlementModel.fromJson,
        ),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SettlementModel> createSettlement({
    required String partnerId,
    required double amount,
    required int settlementType,
    String? notes,
    required bool sendWhatsApp,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.settlements,
        data: {
          'partnerId': partnerId,
          'amount': amount,
          'settlementType': settlementType,
          if (notes != null) 'notes': notes,
          'sendWhatsApp': sendWhatsApp,
        },
      );
      final apiResponse = ApiResponse<SettlementModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            SettlementModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DailySettlementSummaryModel> getDailySummary({String? date}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.settlementDailySummary,
        queryParameters: {if (date != null) 'date': date},
      );
      final apiResponse =
          ApiResponse<DailySettlementSummaryModel>.fromJson(
        response.data!,
        fromJsonT: (data) => DailySettlementSummaryModel.fromJson(
            data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> uploadReceipt(String settlementId, File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.settlementReceipt(settlementId),
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      final apiResponse = ApiResponse<void>.fromJson(response.data!);
      if (!apiResponse.isSuccess) {
        throw ApiException(message: apiResponse.message ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
