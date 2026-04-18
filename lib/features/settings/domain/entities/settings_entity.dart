import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  const SettingsEntity({
    required this.theme,
    required this.language,
    required this.numberFormat,
    required this.focusModeAutoTrigger,
    required this.focusModeSpeedThreshold,
    required this.speedAlertEnabled,
    required this.speedAlertLimit,
    required this.textToSpeechEnabled,
    required this.hapticFeedback,
    required this.highContrastMode,
    required this.notifyNewOrder,
    required this.notifyCashAlert,
    required this.notifyBreakReminder,
    required this.notifyMaintenance,
    required this.notifySettlement,
    required this.notifyAchievement,
    required this.notifySound,
    required this.notifyVibration,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.preferredMapApp,
    required this.maxOrdersPerShift,
    required this.autoSendReceipt,
    required this.locationTrackingInterval,
    required this.offlineSyncInterval,
    required this.homeLatitude,
    required this.homeLongitude,
    required this.homeAddress,
    required this.backToBaseAlertEnabled,
    required this.backToBaseRadiusKm,
  });

  final int theme;
  final String language;
  final int numberFormat;
  final bool focusModeAutoTrigger;
  final int focusModeSpeedThreshold;
  final bool speedAlertEnabled;
  final int speedAlertLimit;
  final bool textToSpeechEnabled;
  final bool hapticFeedback;
  final bool highContrastMode;
  final bool notifyNewOrder;
  final bool notifyCashAlert;
  final bool notifyBreakReminder;
  final bool notifyMaintenance;
  final bool notifySettlement;
  final bool notifyAchievement;
  final bool notifySound;
  final bool notifyVibration;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final int preferredMapApp;
  final int? maxOrdersPerShift;
  final bool autoSendReceipt;
  final int locationTrackingInterval;
  final int offlineSyncInterval;
  final double? homeLatitude;
  final double? homeLongitude;
  final String? homeAddress;
  final bool backToBaseAlertEnabled;
  final double backToBaseRadiusKm;

  SettingsEntity copyWith({
    int? theme,
    String? language,
    int? numberFormat,
    bool? focusModeAutoTrigger,
    int? focusModeSpeedThreshold,
    bool? speedAlertEnabled,
    int? speedAlertLimit,
    bool? textToSpeechEnabled,
    bool? hapticFeedback,
    bool? highContrastMode,
    bool? notifyNewOrder,
    bool? notifyCashAlert,
    bool? notifyBreakReminder,
    bool? notifyMaintenance,
    bool? notifySettlement,
    bool? notifyAchievement,
    bool? notifySound,
    bool? notifyVibration,
    String? quietHoursStart,
    String? quietHoursEnd,
    int? preferredMapApp,
    int? maxOrdersPerShift,
    bool? autoSendReceipt,
    int? locationTrackingInterval,
    int? offlineSyncInterval,
    double? homeLatitude,
    double? homeLongitude,
    String? homeAddress,
    bool? backToBaseAlertEnabled,
    double? backToBaseRadiusKm,
  }) {
    return SettingsEntity(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      numberFormat: numberFormat ?? this.numberFormat,
      focusModeAutoTrigger: focusModeAutoTrigger ?? this.focusModeAutoTrigger,
      focusModeSpeedThreshold:
          focusModeSpeedThreshold ?? this.focusModeSpeedThreshold,
      speedAlertEnabled: speedAlertEnabled ?? this.speedAlertEnabled,
      speedAlertLimit: speedAlertLimit ?? this.speedAlertLimit,
      textToSpeechEnabled: textToSpeechEnabled ?? this.textToSpeechEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      notifyNewOrder: notifyNewOrder ?? this.notifyNewOrder,
      notifyCashAlert: notifyCashAlert ?? this.notifyCashAlert,
      notifyBreakReminder: notifyBreakReminder ?? this.notifyBreakReminder,
      notifyMaintenance: notifyMaintenance ?? this.notifyMaintenance,
      notifySettlement: notifySettlement ?? this.notifySettlement,
      notifyAchievement: notifyAchievement ?? this.notifyAchievement,
      notifySound: notifySound ?? this.notifySound,
      notifyVibration: notifyVibration ?? this.notifyVibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      preferredMapApp: preferredMapApp ?? this.preferredMapApp,
      maxOrdersPerShift: maxOrdersPerShift ?? this.maxOrdersPerShift,
      autoSendReceipt: autoSendReceipt ?? this.autoSendReceipt,
      locationTrackingInterval:
          locationTrackingInterval ?? this.locationTrackingInterval,
      offlineSyncInterval: offlineSyncInterval ?? this.offlineSyncInterval,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      homeAddress: homeAddress ?? this.homeAddress,
      backToBaseAlertEnabled:
          backToBaseAlertEnabled ?? this.backToBaseAlertEnabled,
      backToBaseRadiusKm: backToBaseRadiusKm ?? this.backToBaseRadiusKm,
    );
  }

  /// Apply a dynamic key-value toggle to produce a new entity.
  SettingsEntity applyToggle(String key, bool value) {
    return switch (key) {
      'focusModeAutoTrigger' => copyWith(focusModeAutoTrigger: value),
      'speedAlertEnabled' => copyWith(speedAlertEnabled: value),
      'textToSpeechEnabled' => copyWith(textToSpeechEnabled: value),
      'hapticFeedback' => copyWith(hapticFeedback: value),
      'highContrastMode' => copyWith(highContrastMode: value),
      'notifyNewOrder' => copyWith(notifyNewOrder: value),
      'notifyCashAlert' => copyWith(notifyCashAlert: value),
      'notifyBreakReminder' => copyWith(notifyBreakReminder: value),
      'notifyMaintenance' => copyWith(notifyMaintenance: value),
      'notifySettlement' => copyWith(notifySettlement: value),
      'notifyAchievement' => copyWith(notifyAchievement: value),
      'notifySound' => copyWith(notifySound: value),
      'notifyVibration' => copyWith(notifyVibration: value),
      'autoSendReceipt' => copyWith(autoSendReceipt: value),
      'backToBaseAlertEnabled' => copyWith(backToBaseAlertEnabled: value),
      _ => this,
    };
  }

  @override
  List<Object?> get props => [
        theme,
        language,
        numberFormat,
        focusModeAutoTrigger,
        focusModeSpeedThreshold,
        speedAlertEnabled,
        speedAlertLimit,
        textToSpeechEnabled,
        hapticFeedback,
        highContrastMode,
        notifyNewOrder,
        notifyCashAlert,
        notifyBreakReminder,
        notifyMaintenance,
        notifySettlement,
        notifyAchievement,
        notifySound,
        notifyVibration,
        quietHoursStart,
        quietHoursEnd,
        preferredMapApp,
        maxOrdersPerShift,
        autoSendReceipt,
        locationTrackingInterval,
        offlineSyncInterval,
        homeLatitude,
        homeLongitude,
        homeAddress,
        backToBaseAlertEnabled,
        backToBaseRadiusKm,
      ];
}
