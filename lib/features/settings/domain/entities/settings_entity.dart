import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  const SettingsEntity({
    required this.theme,
    required this.language,
    required this.numberFormat,
    required this.focusModeAutoTrigger,
    required this.focusModeSpeedThreshold,
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

  @override
  List<Object?> get props => [
        theme,
        language,
        numberFormat,
        focusModeAutoTrigger,
        focusModeSpeedThreshold,
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
