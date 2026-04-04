import 'package:equatable/equatable.dart';

class ShiftEntity extends Equatable {
  const ShiftEntity({
    required this.id,
    required this.driverId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.startLatitude,
    required this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    required this.ordersCompleted,
    required this.earningsTotal,
    required this.distanceKm,
  });

  final String id;
  final String driverId;
  final int status; // 0 = ended, 1 = active
  final DateTime startTime;
  final DateTime? endTime;
  final double startLatitude;
  final double startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final int ordersCompleted;
  final double earningsTotal;
  final double distanceKm;

  bool get isActive => status == 1;

  @override
  List<Object?> get props => [
        id,
        driverId,
        status,
        startTime,
        endTime,
        ordersCompleted,
        earningsTotal,
        distanceKm,
      ];
}
