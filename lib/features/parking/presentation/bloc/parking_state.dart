import 'package:equatable/equatable.dart';

import '../../data/models/parking_model.dart';

sealed class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object?> get props => [];
}

final class ParkingInitial extends ParkingState {
  const ParkingInitial();
}

final class ParkingLoading extends ParkingState {
  const ParkingLoading();
}

final class ParkingLoaded extends ParkingState {
  const ParkingLoaded({
    this.spots = const [],
    this.nearbySpots = const [],
    this.isActionInProgress = false,
    this.actionMessage,
    this.isActionError = false,
  });

  final List<ParkingModel> spots;
  final List<ParkingModel> nearbySpots;
  final bool isActionInProgress;
  final String? actionMessage;
  final bool isActionError;

  ParkingLoaded copyWith({
    List<ParkingModel>? spots,
    List<ParkingModel>? nearbySpots,
    bool? isActionInProgress,
    String? Function()? actionMessage,
    bool? isActionError,
  }) {
    return ParkingLoaded(
      spots: spots ?? this.spots,
      nearbySpots: nearbySpots ?? this.nearbySpots,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionMessage:
          actionMessage != null ? actionMessage() : this.actionMessage,
      isActionError: isActionError ?? this.isActionError,
    );
  }

  @override
  List<Object?> get props => [
        spots,
        nearbySpots,
        isActionInProgress,
        actionMessage,
        isActionError,
      ];
}

final class ParkingError extends ParkingState {
  const ParkingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
