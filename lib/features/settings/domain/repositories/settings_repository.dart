import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();

  Future<SettingsEntity> updateSettings(Map<String, dynamic> updates);

  Future<void> updateFocusMode(Map<String, dynamic> data);

  Future<void> updateQuietHours(Map<String, dynamic> data);

  Future<void> updateNotifications(Map<String, dynamic> data);

  Future<void> setHomeLocation(Map<String, dynamic> data);
}
