import 'package:equatable/equatable.dart';

sealed class ColleagueRadarEvent extends Equatable {
  const ColleagueRadarEvent();

  @override
  List<Object?> get props => [];
}

final class ColleagueRadarLoadRequested extends ColleagueRadarEvent {
  const ColleagueRadarLoadRequested({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

final class ColleagueRadarCreateHelpRequest extends ColleagueRadarEvent {
  const ColleagueRadarCreateHelpRequest({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.helpType,
  });

  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String helpType;

  @override
  List<Object?> get props => [title, description, helpType];
}

final class ColleagueRadarRespondRequested extends ColleagueRadarEvent {
  const ColleagueRadarRespondRequested({required this.requestId});
  final String requestId;

  @override
  List<Object?> get props => [requestId];
}

final class ColleagueRadarResolveRequested extends ColleagueRadarEvent {
  const ColleagueRadarResolveRequested({required this.requestId});
  final String requestId;

  @override
  List<Object?> get props => [requestId];
}
