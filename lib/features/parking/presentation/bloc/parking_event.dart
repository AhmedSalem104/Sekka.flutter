import 'package:equatable/equatable.dart';

sealed class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

final class ParkingLoadRequested extends ParkingEvent {
  const ParkingLoadRequested();
}

final class ParkingNearbyRequested extends ParkingEvent {
  const ParkingNearbyRequested({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

final class ParkingCreateRequested extends ParkingEvent {
  const ParkingCreateRequested({
    required this.latitude,
    required this.longitude,
    this.address,
    this.qualityRating = 3,
    this.isPaid = false,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final int qualityRating;
  final bool isPaid;

  @override
  List<Object?> get props => [latitude, longitude, address, qualityRating, isPaid];
}

final class ParkingDeleteRequested extends ParkingEvent {
  const ParkingDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class ParkingClearMessage extends ParkingEvent {
  const ParkingClearMessage();
}
