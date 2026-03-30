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

final class SettingsErrorCleared extends SettingsEvent {
  const SettingsErrorCleared();
}

final class SettingsHomeLocationSet extends SettingsEvent {
  const SettingsHomeLocationSet({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;

  @override
  List<Object?> get props => [latitude, longitude, address];
}

final class SettingsQuietHoursUpdated extends SettingsEvent {
  const SettingsQuietHoursUpdated({
    required this.start,
    required this.end,
  });

  final String start;
  final String end;

  @override
  List<Object?> get props => [start, end];
}
