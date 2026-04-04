import 'package:dio/dio.dart';

import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/referral_model.dart';
import '../models/referral_stats_model.dart';

class ReferralRepository {
  ReferralRepository(this._dio);
  final Dio _dio;

  static const _base = '/api/v1/referrals';

  /// GET /referrals/stats
  Future<ApiResult<ReferralStatsModel>> getStats() async {
    return ApiHelper.execute(
      () => _dio.get('$_base/stats'),
      parser: (data) =>
          ReferralStatsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /referrals
  Future<ApiResult<List<ReferralModel>>> getReferrals() async {
    return ApiHelper.execute(
      () => _dio.get(_base),
      parser: (data) {
        if (data is List) {
          return data
              .map((e) =>
                  ReferralModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (data is Map<String, dynamic> && data.containsKey('items')) {
          return (data['items'] as List)
              .map((e) =>
                  ReferralModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <ReferralModel>[];
      },
    );
  }

  /// GET /referrals/my-code
  Future<ApiResult<String>> getMyCode() async {
    return ApiHelper.execute(
      () => _dio.get('$_base/my-code'),
      parser: (data) {
        if (data is String) return data;
        if (data is Map<String, dynamic>) {
          return data['code'] as String? ??
              data['referralCode'] as String? ??
              '';
        }
        return '';
      },
    );
  }
}
