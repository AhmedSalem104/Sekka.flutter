import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/invoice_model.dart';
import '../models/invoice_summary_model.dart';

class InvoiceRemoteDataSource {
  InvoiceRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  /// GET /invoices — returns flat list (not paginated)
  Future<List<InvoiceModel>> getInvoices({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.invoices,
        queryParameters: {
          'page': pageNumber,
          'pageSize': pageSize,
          if (status != null) 'status': status,
        },
      );
      final json = response.data!;
      final isSuccess = json['isSuccess'] as bool? ?? false;
      if (!isSuccess) {
        throw ApiException(message: json['message'] as String? ?? '');
      }

      final data = json['data'];
      if (data is List) {
        return data
            .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // If paginated response
      if (data is Map<String, dynamic> && data.containsKey('items')) {
        return (data['items'] as List)
            .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<InvoiceModel> getInvoiceDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.invoiceDetail(id),
      );
      final apiResponse = ApiResponse<InvoiceModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            InvoiceModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<int>> downloadInvoicePdf(String id) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConstants.invoicePdf(id),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<InvoiceSummaryModel> getInvoiceSummary() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.invoicesSummary,
      );
      final json = response.data!;
      final isSuccess = json['isSuccess'] as bool? ?? false;
      if (!isSuccess) {
        throw ApiException(message: json['message'] as String? ?? '');
      }

      final data = json['data'] as Map<String, dynamic>? ?? {};
      return InvoiceSummaryModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
