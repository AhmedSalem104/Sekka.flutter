import '../../../../shared/utils/safe_parse.dart';
import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.theme,
    required super.language,
    required super.numberFormat,
    required super.focusModeAutoTrigger,
    required super.focusModeSpeedThreshold,
    required super.speedAlertEnabled,
    required super.speedAlertLimit,
    required super.textToSpeechEnabled,
    required super.hapticFeedback,
    required super.highContrastMode,
    required super.notifyNewOrder,
    required super.notifyCashAlert,
    required super.notifyBreakReminder,
    required super.notifyMaintenance,
    required super.notifySettlement,
    required super.notifyAchievement,
    required super.notifySound,
    required super.notifyVibration,
    required super.quietHoursStart,
    required super.quietHoursEnd,
    required super.preferredMapApp,
    required super.maxOrdersPerShift,
    required super.autoSendReceipt,
    required super.locationTrackingInterval,
    required super.offlineSyncInterval,
    required super.homeLatitude,
    required super.homeLongitude,
    required super.homeAddress,
    required super.backToBaseAlertEnabled,
    required super.backToBaseRadiusKm,
  });

  static int _parseTheme(dynamic v) {
    if (v is int) return v;
    if (v is String) {
      const map = {'system': 0, 'light': 1, 'dark': 2};
      return map[v.toLowerCase()] ?? 1;
    }
    return 1; // default light
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      theme: _parseTheme(json['theme']),
      language: json['language'] as String? ?? 'ar',
      numberFormat: safeInt(json['numberFormat'], 0),
      focusModeAutoTrigger: json['focusModeAutoTrigger'] as bool? ?? true,
      focusModeSpeedThreshold: safeInt(json['focusModeSpeedThreshold'], 20),
      speedAlertEnabled: json['speedAlertEnabled'] as bool? ?? false,
      speedAlertLimit: safeInt(json['speedAlertLimit'], 60),
      textToSpeechEnabled: json['textToSpeechEnabled'] as bool? ?? false,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      highContrastMode: json['highContrastMode'] as bool? ?? false,
      notifyNewOrder: json['notifyNewOrder'] as bool? ?? true,
      notifyCashAlert: json['notifyCashAlert'] as bool? ?? true,
      notifyBreakReminder: json['notifyBreakReminder'] as bool? ?? true,
      notifyMaintenance: json['notifyMaintenance'] as bool? ?? true,
      notifySettlement: json['notifySettlement'] as bool? ?? true,
      notifyAchievement: json['notifyAchievement'] as bool? ?? true,
      notifySound: json['notifySound'] as bool? ?? true,
      notifyVibration: json['notifyVibration'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      preferredMapApp: safeInt(json['preferredMapApp'], 0),
      maxOrdersPerShift: json['maxOrdersPerShift'] is int ? json['maxOrdersPerShift'] as int : (json['maxOrdersPerShift'] is String ? int.tryParse(json['maxOrdersPerShift'] as String) : null),
      autoSendReceipt: json['autoSendReceipt'] as bool? ?? true,
      locationTrackingInterval:
          safeInt(json['locationTrackingInterval'], 10),
      offlineSyncInterval: safeInt(json['offlineSyncInterval'], 30),
      homeLatitude: (json['homeLatitude'] as num?)?.toDouble(),
      homeLongitude: (json['homeLongitude'] as num?)?.toDouble(),
      homeAddress: json['homeAddress'] as String?,
      backToBaseAlertEnabled:
          json['backToBaseAlertEnabled'] as bool? ?? false,
      backToBaseRadiusKm:
          (json['backToBaseRadiusKm'] as num?)?.toDouble() ?? 2.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'language': language,
        'numberFormat': numberFormat,
        'focusModeAutoTrigger': focusModeAutoTrigger,
        'focusModeSpeedThreshold': focusModeSpeedThreshold,
        'speedAlertEnabled': speedAlertEnabled,
        'speedAlertLimit': speedAlertLimit,
        'textToSpeechEnabled': textToSpeechEnabled,
        'hapticFeedback': hapticFeedback,
        'highContrastMode': highContrastMode,
        'notifyNewOrder': notifyNewOrder,
        'notifyCashAlert': notifyCashAlert,
        'notifyBreakReminder': notifyBreakReminder,
        'notifyMaintenance': notifyMaintenance,
        'notifySettlement': notifySettlement,
        'notifyAchievement': notifyAchievement,
        'notifySound': notifySound,
        'notifyVibration': notifyVibration,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'preferredMapApp': preferredMapApp,
        'maxOrdersPerShift': maxOrdersPerShift,
        'autoSendReceipt': autoSendReceipt,
        'locationTrackingInterval': locationTrackingInterval,
        'offlineSyncInterval': offlineSyncInterval,
        'homeLatitude': homeLatitude,
        'homeLongitude': homeLongitude,
        'homeAddress': homeAddress,
        'backToBaseAlertEnabled': backToBaseAlertEnabled,
        'backToBaseRadiusKm': backToBaseRadiusKm,
      };
}
