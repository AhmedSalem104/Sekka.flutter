import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/app_notice_model.dart';
import '../models/feature_flags_model.dart';
import '../models/version_check_model.dart';

class AppConfigRepository {
  const AppConfigRepository(this._dio);

  final Dio _dio;

  /// Current app version — update this with each release.
  static const String appVersion = '1.0.0';

  /// GET /config/check-version?platform={0|1}&currentVersion={version}
  Future<ApiResult<VersionCheckModel>> checkVersion() async {
    final platform = Platform.isIOS ? 0 : 1;

    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.configCheckVersion,
        queryParameters: {
          'platform': platform,
          'currentVersion': appVersion,
        },
      ),
      parser: (data) =>
          VersionCheckModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /config/notices
  Future<ApiResult<List<AppNoticeModel>>> getNotices() => ApiHelper.execute(
        () => _dio.get(ApiConstants.configNotices),
        parser: (data) => (data as List<dynamic>)
            .map((e) => AppNoticeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// GET /config/features
  Future<ApiResult<FeatureFlagsModel>> getFeatures() => ApiHelper.execute(
        () => _dio.get(ApiConstants.configFeatures),
        parser: (data) =>
            FeatureFlagsModel.fromJson(data as Map<String, dynamic>),
      );
}
