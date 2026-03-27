import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required SettingsRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final SettingsRemoteDataSource _remote;

  @override
  Future<SettingsEntity> getSettings() => _remote.getSettings();

  @override
  Future<SettingsEntity> updateSettings(Map<String, dynamic> updates) =>
      _remote.updateSettings(updates);

  @override
  Future<void> updateFocusMode(Map<String, dynamic> data) =>
      _remote.updateFocusMode(data);

  @override
  Future<void> updateQuietHours(Map<String, dynamic> data) =>
      _remote.updateQuietHours(data);

  @override
  Future<void> updateNotifications(Map<String, dynamic> data) =>
      _remote.updateNotifications(data);

  @override
  Future<void> setHomeLocation(Map<String, dynamic> data) =>
      _remote.setHomeLocation(data);
}
