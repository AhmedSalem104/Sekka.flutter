import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsUpdateRequested>(_onUpdate);
    on<SettingsToggled>(_onToggle);
  }

  final SettingsRepository _repository;

  Future<void> _onLoad(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } on ApiException catch (e) {
      emit(SettingsError(e.message));
    } catch (_) {
      emit(const SettingsError(AppStrings.unknownError));
    }
  }

  Future<void> _onUpdate(
    SettingsUpdateRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    emit(current.copyWith(isSaving: true));

    try {
      final updated = await _repository.updateSettings(event.updates);
      emit(SettingsLoaded(settings: updated));
    } on ApiException catch (e) {
      // Revert to previous state on error
      emit(current.copyWith(isSaving: false));
      emit(SettingsError(e.message));
    } catch (_) {
      emit(current.copyWith(isSaving: false));
    }
  }

  Future<void> _onToggle(
    SettingsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    // Optimistic update — send to API in background
    add(SettingsUpdateRequested({event.key: event.value}));
  }
}
