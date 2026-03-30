import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/daily_settlement_summary_model.dart';
import '../models/partner_balance_model.dart';
import '../models/settlement_model.dart';

class SettlementRemoteDataSource {
  SettlementRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<List<SettlementModel>> getSettlements({
    int page = 1,
    int pageSize = 20,
    String? partnerId,
    int? settlementType,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.settlements,
        queryParameters: {
          'Page': page,
          'PageSize': pageSize,
          if (partnerId != null) 'PartnerId': partnerId,
          if (settlementType != null) 'SettlementType': settlementType,
          if (dateFrom != null) 'DateFrom': dateFrom,
          if (dateTo != null) 'DateTo': dateTo,
        },
      );
      final apiResponse = ApiResponse<List<SettlementModel>>.fromJson(
        response.data!,
        fromJsonT: (data) => (data as List<dynamic>)
            .map(
              (e) => SettlementModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
      if (!apiResponse.isSuccess) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SettlementModel> createSettlement({
    required String partnerId,
    required double amount,
    required int settlementType,
    int orderCount = 0,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.settlements,
        data: {
          'partnerId': partnerId,
          'amount': amount,
          'settlementType': settlementType,
          'orderCount': orderCount,
          if (notes != null) 'notes': notes,
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

  Future<PartnerBalanceModel> getPartnerBalance(String partnerId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.settlementPartnerBalance(partnerId),
      );
      final apiResponse = ApiResponse<PartnerBalanceModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            PartnerBalanceModel.fromJson(data as Map<String, dynamic>),
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
