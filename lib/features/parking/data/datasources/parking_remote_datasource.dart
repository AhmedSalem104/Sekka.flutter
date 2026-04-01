import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/parking_model.dart';

class ParkingRemoteDataSource {
  ParkingRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  /// GET /parking
  Future<List<ParkingModel>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.parking,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      final data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => ParkingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /parking
  Future<ParkingModel> create({
    required double latitude,
    required double longitude,
    String? address,
    int qualityRating = 3,
    bool isPaid = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.parking,
        data: <String, dynamic>{
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
          'qualityRating': qualityRating,
          'isPaid': isPaid,
        },
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return ParkingModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT /parking/{id}
  Future<ParkingModel> update(String id, ParkingModel model) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.parkingDetail(id),
        data: model.toJson(),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return ParkingModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// DELETE /parking/{id}
  Future<void> delete(String id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        ApiConstants.parkingDetail(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /parking/nearby?latitude=...&longitude=...
  Future<List<ParkingModel>> getNearby({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.parkingNearby,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      final data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => ParkingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
