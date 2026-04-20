import '../../../../shared/utils/safe_parse.dart';
import 'package:equatable/equatable.dart';

class NearbyDriverModel extends Equatable {
  const NearbyDriverModel({
    required this.driverId,
    required this.driverName,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.vehicleType,
    this.isOnline = true,
  });

  final String driverId;
  final String driverName;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int? vehicleType;
  final bool isOnline;

  factory NearbyDriverModel.fromJson(Map<String, dynamic> json) {
    return NearbyDriverModel(
      driverId: json['driverId'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      vehicleType: parseVehicleType(json['vehicleType']),
      isOnline: json['isOnline'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [driverId, distanceKm];
}
