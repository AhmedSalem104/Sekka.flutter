import 'data/models/app_notice_model.dart';
import 'data/models/feature_flags_model.dart';
import 'data/models/version_check_model.dart';

/// Singleton that holds the app config loaded at startup.
/// Accessible anywhere without context.
class AppConfigService {
  AppConfigService._();
  static final instance = AppConfigService._();

  VersionCheckModel? _versionCheck;
  FeatureFlagsModel _features = const FeatureFlagsModel(features: {});
  List<AppNoticeModel> _notices = [];

  VersionCheckModel? get versionCheck => _versionCheck;
  FeatureFlagsModel get features => _features;
  List<AppNoticeModel> get notices => _notices;

  bool get needsForceUpdate =>
      _versionCheck != null && _versionCheck!.isForceUpdate;

  bool isFeatureEnabled(String key) => _features.isEnabled(key);

  void setVersionCheck(VersionCheckModel value) => _versionCheck = value;
  void setFeatures(FeatureFlagsModel value) => _features = value;
  void setNotices(List<AppNoticeModel> value) => _notices = value;
}
