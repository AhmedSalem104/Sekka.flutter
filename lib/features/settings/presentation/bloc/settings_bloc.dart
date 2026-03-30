import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required SettingsRepository repository,
    required this.themeModeNotifier,
    required this.localeNotifier,
  })  : _repository = repository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsUpdateRequested>(_onUpdate);
    on<SettingsToggled>(_onToggle);
    on<SettingsErrorCleared>(_onErrorCleared);
    on<SettingsHomeLocationSet>(_onSetHomeLocation);
    on<SettingsQuietHoursUpdated>(_onUpdateQuietHours);
  }

  final SettingsRepository _repository;
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final ValueNotifier<Locale> localeNotifier;

  static const _notificationKeys = {
    'notifyNewOrder',
    'notifyCashAlert',
    'notifyBreakReminder',
    'notifyMaintenance',
    'notifySettlement',
    'notifyAchievement',
    'notifySound',
    'notifyVibration',
  };

  static const _focusModeKeys = {
    'focusModeAutoTrigger',
    'focusModeSpeedThreshold',
  };

  // ── Load ──────────────────────────────────────────────

  Future<void> _onLoad(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      _syncNotifiers(settings.theme, settings.language);
      emit(SettingsLoaded(settings: settings));
    } on ApiException catch (e) {
      emit(SettingsError(e.message));
    } catch (_) {
      emit(SettingsError(AppStrings.unknownError));
    }
  }

  // ── Update (general) ─────────────────────────────────

  Future<void> _onUpdate(
    SettingsUpdateRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    // Optimistic update for known fields
    var optimistic = current.settings;
    for (final entry in event.updates.entries) {
      optimistic = _applyField(optimistic, entry.key, entry.value);
    }
    emit(SettingsLoaded(settings: optimistic, isSaving: true));

    try {
      // Route to specialized endpoint if all keys belong to one category
      final keys = event.updates.keys.toSet();

      if (keys.every(_notificationKeys.contains)) {
        await _repository.updateNotifications(event.updates);
      } else if (keys.every(_focusModeKeys.contains)) {
        await _repository.updateFocusMode(event.updates);
      } else {
        await _repository.updateSettings(event.updates);
      }

      // Sync theme/locale notifiers if changed
      if (event.updates.containsKey('theme') ||
          event.updates.containsKey('language')) {
        _syncNotifiers(optimistic.theme, optimistic.language);
      }

      emit(SettingsLoaded(settings: optimistic));
    } on ApiException catch (e) {
      // Revert to previous state and show error
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(isSaving: false, errorMessage: AppStrings.unknownError));
    }
  }

  // ── Toggle ────────────────────────────────────────────

  Future<void> _onToggle(
    SettingsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    // Optimistic UI update
    final optimistic = current.settings.applyToggle(event.key, event.value);
    emit(SettingsLoaded(settings: optimistic, isSaving: true));

    try {
      final data = {event.key: event.value};

      if (_notificationKeys.contains(event.key)) {
        await _repository.updateNotifications(data);
      } else if (_focusModeKeys.contains(event.key)) {
        await _repository.updateFocusMode(data);
      } else {
        await _repository.updateSettings(data);
      }

      emit(SettingsLoaded(settings: optimistic));
    } on ApiException catch (e) {
      // Revert
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(isSaving: false, errorMessage: AppStrings.unknownError));
    }
  }

  // ── Home Location ─────────────────────────────────────

  Future<void> _onSetHomeLocation(
    SettingsHomeLocationSet event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    emit(current.copyWith(isSaving: true));

    try {
      await _repository.setHomeLocation({
        'latitude': event.latitude,
        'longitude': event.longitude,
        'address': event.address,
      });

      final updated = current.settings.copyWith(
        homeLatitude: event.latitude,
        homeLongitude: event.longitude,
        homeAddress: event.address,
      );
      emit(SettingsLoaded(settings: updated));
    } on ApiException catch (e) {
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(isSaving: false, errorMessage: AppStrings.unknownError));
    }
  }

  // ── Quiet Hours ───────────────────────────────────────

  Future<void> _onUpdateQuietHours(
    SettingsQuietHoursUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    final optimistic = current.settings.copyWith(
      quietHoursStart: event.start,
      quietHoursEnd: event.end,
    );
    emit(SettingsLoaded(settings: optimistic, isSaving: true));

    try {
      await _repository.updateQuietHours({
        'quietHoursStart': event.start,
        'quietHoursEnd': event.end,
      });
      emit(SettingsLoaded(settings: optimistic));
    } on ApiException catch (e) {
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(isSaving: false, errorMessage: AppStrings.unknownError));
    }
  }

  // ── Error cleared ─────────────────────────────────────

  void _onErrorCleared(
    SettingsErrorCleared event,
    Emitter<SettingsState> emit,
  ) {
    final current = state;
    if (current is SettingsLoaded) {
      emit(current.copyWith(errorMessage: null));
    }
  }

  // ── Helpers ───────────────────────────────────────────

  void _syncNotifiers(int theme, String language) {
    themeModeNotifier.value = switch (theme) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    localeNotifier.value = Locale(language);
    AppStrings.setLocale(language);
  }

  /// Apply a dynamic key-value pair to the entity.
  static SettingsEntity _applyField(
    SettingsEntity entity,
    String key,
    dynamic value,
  ) {
    if (value is bool) return entity.applyToggle(key, value);
    return switch (key) {
      'theme' => entity.copyWith(theme: value as int),
      'language' => entity.copyWith(language: value as String),
      'numberFormat' => entity.copyWith(numberFormat: value as int),
      'focusModeSpeedThreshold' =>
        entity.copyWith(focusModeSpeedThreshold: value as int),
      'preferredMapApp' => entity.copyWith(preferredMapApp: value as int),
      'maxOrdersPerShift' => entity.copyWith(maxOrdersPerShift: value as int),
      'locationTrackingInterval' =>
        entity.copyWith(locationTrackingInterval: value as int),
      'offlineSyncInterval' =>
        entity.copyWith(offlineSyncInterval: value as int),
      'backToBaseRadiusKm' =>
        entity.copyWith(backToBaseRadiusKm: value as double),
      _ => entity,
    };
  }
}
