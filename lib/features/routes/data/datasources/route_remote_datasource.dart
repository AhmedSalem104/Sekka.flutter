import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/route_model.dart';

class RouteRemoteDataSource {
  RouteRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  /// POST /routes/optimize
  Future<RouteModel> optimizeRoute({
    List<String>? orderIds,
    double? startLatitude,
    double? startLongitude,
    String? optimizationType,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.routesOptimize,
        data: <String, dynamic>{
          if (orderIds != null && orderIds.isNotEmpty) 'orderIds': orderIds,
          if (startLatitude != null) 'startLatitude': startLatitude,
          if (startLongitude != null) 'startLongitude': startLongitude,
          if (optimizationType != null) 'optimizationType': optimizationType,
        },
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      final data = json['data'] as Map<String, dynamic>;
      return RouteModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /routes/active
  Future<RouteModel?> getActiveRoute() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.routesActive,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        return null;
      }
      final data = json['data'];
      if (data == null) return null;
      return RouteModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /routes/:id/reorder
  Future<RouteModel> reorderRoute(
    String id,
    List<String> orderIds,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.routeReorder(id),
        data: {'orderIds': orderIds},
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return RouteModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /routes/:id/add-order
  Future<RouteModel> addOrderToRoute(
    String id,
    String orderId,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.routeAddOrder(id),
        data: {'orderId': orderId},
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return RouteModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /routes/:id/complete
  Future<RouteModel> completeRoute(String id) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.routeComplete(id),
        data: <String, dynamic>{},
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return RouteModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
