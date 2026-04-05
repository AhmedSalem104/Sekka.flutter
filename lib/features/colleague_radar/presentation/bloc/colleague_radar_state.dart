import 'package:equatable/equatable.dart';

import '../../data/models/help_request_model.dart';
import '../../data/models/nearby_driver_model.dart';

sealed class ColleagueRadarState extends Equatable {
  const ColleagueRadarState();

  @override
  List<Object?> get props => [];
}

final class ColleagueRadarInitial extends ColleagueRadarState {
  const ColleagueRadarInitial();
}

final class ColleagueRadarLoading extends ColleagueRadarState {
  const ColleagueRadarLoading();
}

final class ColleagueRadarLoaded extends ColleagueRadarState {
  const ColleagueRadarLoaded({
    required this.nearbyDrivers,
    required this.nearbyRequests,
    required this.myRequests,
    this.isSubmitting = false,
    this.actionMessage,
  });

  final List<NearbyDriverModel> nearbyDrivers;
  final List<HelpRequestModel> nearbyRequests;
  final List<HelpRequestModel> myRequests;
  final bool isSubmitting;
  final String? actionMessage;

  ColleagueRadarLoaded copyWith({
    List<NearbyDriverModel>? nearbyDrivers,
    List<HelpRequestModel>? nearbyRequests,
    List<HelpRequestModel>? myRequests,
    bool? isSubmitting,
    String? actionMessage,
  }) =>
      ColleagueRadarLoaded(
        nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
        nearbyRequests: nearbyRequests ?? this.nearbyRequests,
        myRequests: myRequests ?? this.myRequests,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        actionMessage: actionMessage,
      );

  @override
  List<Object?> get props => [
        nearbyDrivers,
        nearbyRequests,
        myRequests,
        isSubmitting,
        actionMessage,
      ];
}

final class ColleagueRadarError extends ColleagueRadarState {
  const ColleagueRadarError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
