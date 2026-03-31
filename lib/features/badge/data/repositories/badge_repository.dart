import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/badge_model.dart';
import '../models/badge_verify_model.dart';

class BadgeRepository {
  const BadgeRepository(this._dio);

  final Dio _dio;

  /// GET /badge — returns the authenticated driver's badge.
  Future<ApiResult<BadgeModel>> getBadge() => ApiHelper.execute(
        () => _dio.get(ApiConstants.badge),
        parser: (data) => BadgeModel.fromJson(data as Map<String, dynamic>),
      );

  /// GET /badge/verify/{qrToken} — verifies a QR token.
  Future<ApiResult<BadgeVerifyModel>> verifyBadge(String qrToken) =>
      ApiHelper.execute(
        () => _dio.get(ApiConstants.badgeVerify(qrToken)),
        parser: (data) =>
            BadgeVerifyModel.fromJson(data as Map<String, dynamic>),
      );
}
