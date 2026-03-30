import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../../shared/network/paginated_response.dart';
import '../models/cash_status_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_balance_model.dart';
import '../models/wallet_summary_model.dart';

class WalletRemoteDataSource {
  WalletRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<WalletBalanceModel> getBalance() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.walletBalance);
      final apiResponse = ApiResponse<WalletBalanceModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            WalletBalanceModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int pageNumber = 1,
    int pageSize = 20,
    int? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'Page': pageNumber,
        'PageSize': pageSize,
        if (type != null) 'TransactionType': type,
        if (dateFrom != null) 'DateFrom': dateFrom,
        if (dateTo != null) 'DateTo': dateTo,
      };
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.walletTransactions,
        queryParameters: queryParams,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }

      final data = json['data'];

      // Handle both paginated (Map with items) and plain List responses
      if (data is Map<String, dynamic>) {
        return PaginatedResponse.fromJson(
          data,
          fromJsonT: TransactionModel.fromJson,
        );
      }

      // Plain list — wrap in a PaginatedResponse
      final items = (data as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedResponse<TransactionModel>(
        items: items,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalCount: items.length,
        totalPages: 1,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WalletSummaryModel> getSummary({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.walletSummary,
        queryParameters: queryParams,
      );
      final apiResponse = ApiResponse<WalletSummaryModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            WalletSummaryModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CashStatusModel> getCashStatus() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.walletCashStatus);
      final apiResponse = ApiResponse<CashStatusModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            CashStatusModel.fromJson(data as Map<String, dynamic>),
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
