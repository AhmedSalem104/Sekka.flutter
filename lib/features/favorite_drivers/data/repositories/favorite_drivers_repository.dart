import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/favorite_driver_model.dart';

class FavoriteDriversRepository {
  const FavoriteDriversRepository(this._dio);

  final Dio _dio;

  /// GET /favorite-drivers
  Future<ApiResult<List<FavoriteDriverModel>>> getFavorites() =>
      ApiHelper.execute(
        () => _dio.get(ApiConstants.favoriteDrivers),
        parser: (data) => (data as List<dynamic>)
            .map((e) =>
                FavoriteDriverModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// POST /favorite-drivers
  Future<ApiResult<FavoriteDriverModel>> addFavorite({
    required String name,
    required String phone,
  }) =>
      ApiHelper.execute(
        () => _dio.post(
          ApiConstants.favoriteDrivers,
          data: {'name': name, 'phone': phone},
        ),
        parser: (data) =>
            FavoriteDriverModel.fromJson(data as Map<String, dynamic>),
      );

  /// DELETE /favorite-drivers/{id}
  Future<ApiResult<bool>> removeFavorite(String id) => ApiHelper.execute(
        () => _dio.delete(ApiConstants.favoriteDriverDetail(id)),
        parser: (data) => data as bool,
      );

  /// PUT /favorite-drivers/{id}/refresh
  Future<ApiResult<FavoriteDriverModel>> refreshFavorite(String id) =>
      ApiHelper.execute(
        () => _dio.put(
          ApiConstants.favoriteDriverRefresh(id),
          data: {},
        ),
        parser: (data) =>
            FavoriteDriverModel.fromJson(data as Map<String, dynamic>),
      );

  /// GET /drivers/by-phone/{phone}
  Future<ApiResult<DriverByPhoneModel>> searchByPhone(String phone) =>
      ApiHelper.execute(
        () => _dio.get(ApiConstants.driverByPhone(phone)),
        parser: (data) =>
            DriverByPhoneModel.fromJson(data as Map<String, dynamic>),
      );

  /// POST /orders/{id}/share-link
  Future<ApiResult<ShareLinkModel>> createShareLink(
    String orderId, {
    int? ttlMinutes,
  }) =>
      ApiHelper.execute(
        () => _dio.post(
          ApiConstants.orderShareLink(orderId),
          queryParameters: {
            if (ttlMinutes != null) 'ttlMinutes': ttlMinutes,
          },
        ),
        parser: (data) =>
            ShareLinkModel.fromJson(data as Map<String, dynamic>),
      );
}
