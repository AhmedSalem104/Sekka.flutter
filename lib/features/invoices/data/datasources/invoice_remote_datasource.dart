import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../../shared/network/paginated_response.dart';
import '../models/invoice_model.dart';
import '../models/invoice_summary_model.dart';

class InvoiceRemoteDataSource {
  InvoiceRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<PaginatedResponse<InvoiceModel>> getInvoices({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.invoices,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (status != null) 'status': status,
        },
      );
      final apiResponse =
          ApiResponse<PaginatedResponse<InvoiceModel>>.fromJson(
        response.data!,
        fromJsonT: (data) => PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          fromJsonT: InvoiceModel.fromJson,
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
      final apiResponse = ApiResponse<InvoiceSummaryModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            InvoiceSummaryModel.fromJson(data as Map<String, dynamic>),
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
