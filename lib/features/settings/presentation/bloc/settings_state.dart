import 'package:equatable/equatable.dart';

import '../../domain/entities/settings_entity.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.settings,
    this.isSaving = false,
    this.errorMessage,
  });

  final SettingsEntity settings;
  final bool isSaving;
  final String? errorMessage;

  SettingsLoaded copyWith({
    SettingsEntity? settings,
    bool? isSaving,
    String? errorMessage,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [settings, isSaving, errorMessage];
}

/// Only used when initial load fails and there is no data to show.
final class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
