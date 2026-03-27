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
  });

  final SettingsEntity settings;
  final bool isSaving;

  SettingsLoaded copyWith({
    SettingsEntity? settings,
    bool? isSaving,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [settings, isSaving];
}

final class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
