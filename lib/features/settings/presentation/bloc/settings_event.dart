import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

final class SettingsUpdateRequested extends SettingsEvent {
  const SettingsUpdateRequested(this.updates);

  final Map<String, dynamic> updates;

  @override
  List<Object?> get props => [updates];
}

final class SettingsToggled extends SettingsEvent {
  const SettingsToggled(this.key, this.value);

  final String key;
  final bool value;

  @override
  List<Object?> get props => [key, value];
}
