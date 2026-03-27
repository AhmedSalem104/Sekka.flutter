import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../../shared/network/paginated_response.dart';
import '../models/payment_request_model.dart';

class PaymentRemoteDataSource {
  PaymentRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<PaginatedResponse<PaymentRequestModel>> getPaymentRequests({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.paymentRequests,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (status != null) 'status': status,
        },
      );
      final apiResponse =
          ApiResponse<PaginatedResponse<PaymentRequestModel>>.fromJson(
        response.data!,
        fromJsonT: (data) => PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          fromJsonT: PaymentRequestModel.fromJson,
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

  Future<PaymentRequestModel> getPaymentRequestDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.paymentRequestDetail(id),
      );
      final apiResponse = ApiResponse<PaymentRequestModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            PaymentRequestModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PaymentRequestModel> createPaymentRequest({
    required String planId,
    required int paymentMethod,
    String? senderPhone,
    String? senderName,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.paymentRequests,
        data: {
          'planId': planId,
          'paymentMethod': paymentMethod,
          if (senderPhone != null) 'senderPhone': senderPhone,
          if (senderName != null) 'senderName': senderName,
          if (notes != null) 'notes': notes,
        },
      );
      final apiResponse = ApiResponse<PaymentRequestModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            PaymentRequestModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> uploadProof(String requestId, File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      await _dio.post<Map<String, dynamic>>(
        ApiConstants.paymentRequestProof(requestId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> cancelPaymentRequest(String id) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiConstants.paymentRequestDetail(id),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
