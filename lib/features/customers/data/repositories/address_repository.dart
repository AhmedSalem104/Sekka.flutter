import 'package:dio/dio.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/address_model.dart';

class AddressRepository {
    AddressRepository(this._dio);
  final Dio _dio;

  /// GET /api/v1/addresses/search
  Future<ApiResult<List<AddressModel>>> searchAddresses({
    String? searchTerm,
    String? customerId,
    int? addressType,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/addresses/search',
        queryParameters: {
          if (searchTerm != null) 'searchTerm': searchTerm,
          if (customerId != null) 'customerId': customerId,
          if (addressType != null) 'addressType': addressType,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      ),
      parser: (data) => (data as List<dynamic>)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// POST /api/v1/addresses
  Future<ApiResult<AddressModel>> saveAddress({
    String? customerId,
    required String addressText,
    double? latitude,
    double? longitude,
    required int addressType,
    String? landmarks,
    String? deliveryNotes,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        '/addresses',
        data: {
          if (customerId != null) 'customerId': customerId,
          'addressText': addressText,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'addressType': addressType,
          if (landmarks != null) 'landmarks': landmarks,
          if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
        },
      ),
      parser: (data) => AddressModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /api/v1/addresses/{id}
  Future<ApiResult<AddressModel>> updateAddress(
    String id, {
    String? addressText,
    double? latitude,
    double? longitude,
    int? addressType,
    String? landmarks,
    String? deliveryNotes,
  }) async {
    return ApiHelper.execute(
      () => _dio.put(
        '/addresses/$id',
        data: {
          if (addressText != null) 'addressText': addressText,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (addressType != null) 'addressType': addressType,
          if (landmarks != null) 'landmarks': landmarks,
          if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
        },
      ),
      parser: (data) => AddressModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// DELETE /api/v1/addresses/{id}
  Future<ApiResult<bool>> deleteAddress(String id) async {
    return ApiHelper.execute(
      () => _dio.delete('/addresses/$id'),
      parser: (data) => data as bool,
    );
  }

  /// GET /api/v1/addresses/autocomplete
  Future<ApiResult<List<AddressModel>>> autocomplete(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/addresses/autocomplete',
        queryParameters: {
          'q': query,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      ),
      parser: (data) => (data as List<dynamic>)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// GET /api/v1/addresses/nearby
  Future<ApiResult<List<AddressModel>>> nearby({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/addresses/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          if (radiusKm != null) 'radiusKm': radiusKm,
        },
      ),
      parser: (data) => (data as List<dynamic>)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
