import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  /// POST /orders — create a new order.
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orders,
        data: data,
      );
      final apiResponse = ApiResponse<OrderModel>.fromJson(
        response.data!,
        fromJsonT: (json) =>
            OrderModel.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /orders — paginated list with filters.
  Future<PagedData<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? partnerId,
    String? dateFrom,
    String? dateTo,
    String? searchTerm,
    int? paymentMethod,
    int? priority,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
        if (partnerId != null) 'partnerId': partnerId,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
        if (searchTerm != null) 'searchTerm': searchTerm,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (priority != null) 'priority': priority,
      };
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.orders,
        queryParameters: queryParams,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return PagedData<OrderModel>.fromJson(
        json['data'] as Map<String, dynamic>,
        OrderModel.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /orders/:id — single order detail.
  Future<OrderModel> getOrderDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.orderDetail(id),
      );
      final apiResponse = ApiResponse<OrderModel>.fromJson(
        response.data!,
        fromJsonT: (json) =>
            OrderModel.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /orders/:id — update an order.
  Future<OrderModel> updateOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.orderDetail(id),
        data: data,
      );
      final apiResponse = ApiResponse<OrderModel>.fromJson(
        response.data!,
        fromJsonT: (json) =>
            OrderModel.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// DELETE /orders/:id — delete an order.
  Future<void> deleteOrder(String id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        ApiConstants.orderDetail(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /orders/:id/status — update order status.
  Future<Map<String, dynamic>> updateOrderStatus(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.orderStatus(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/deliver — mark order as delivered.
  Future<Map<String, dynamic>> deliverOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderDeliver(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/fail — mark order as failed.
  Future<Map<String, dynamic>> failOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderFail(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/cancel — cancel an order.
  Future<Map<String, dynamic>> cancelOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderCancel(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/transfer — transfer an order.
  Future<Map<String, dynamic>> transferOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderTransfer(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/partial — partial delivery.
  Future<Map<String, dynamic>> partialDelivery(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderPartial(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/bulk — bulk import orders.
  Future<Map<String, dynamic>> bulkImport(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.ordersBulk,
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/check-duplicate — check for duplicate orders.
  Future<Map<String, dynamic>> checkDuplicate(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.ordersCheckDuplicate,
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/worth — calculate order worth.
  Future<Map<String, dynamic>> calculateWorth(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderWorth(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/photos — upload a photo (multipart).
  Future<Map<String, dynamic>> uploadPhoto(
    String id,
    File imageFile,
    int photoType, {
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'photoType': photoType,
        if (description != null) 'description': description,
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderPhotos(id),
        data: formData,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/swap-address — swap sender/receiver address.
  Future<Map<String, dynamic>> swapAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderSwapAddress(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/waiting/start — start waiting timer.
  Future<Map<String, dynamic>> startWaitingTimer(
    String id, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderWaitingStart(id),
        data: body,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/waiting/stop — stop waiting timer.
  Future<Map<String, dynamic>> stopWaitingTimer(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderWaitingStop(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/calculate-price — calculate delivery price.
  Future<Map<String, dynamic>> calculatePrice(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.ordersCalculatePrice,
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/disclaimer — post disclaimer.
  Future<Map<String, dynamic>> postDisclaimer(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderDisclaimer(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /orders/:id/disclaimer — get disclaimer.
  Future<Map<String, dynamic>> getDisclaimer(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.orderDisclaimer(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/dispute — post dispute.
  Future<Map<String, dynamic>> postDispute(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderDispute(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /orders/:id/disputes — get disputes list.
  Future<List<dynamic>> getDisputes(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.orderDisputes(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/refund — post refund.
  Future<Map<String, dynamic>> postRefund(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderRefund(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /orders/:id/refunds — get refunds list.
  Future<List<dynamic>> getRefunds(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.orderRefunds(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /orders/time-slots — get available time slots.
  Future<List<dynamic>> getTimeSlots() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.ordersTimeSlots,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as List<dynamic>? ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /orders/:id/book-slot — book a time slot.
  Future<Map<String, dynamic>> bookSlot(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.orderBookSlot(id),
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
