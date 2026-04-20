import '../../../../shared/utils/safe_parse.dart';
import 'package:equatable/equatable.dart';

class BadgeVerifyModel extends Equatable {
  const BadgeVerifyModel({
    required this.isValid,
    required this.isActive,
    required this.verifiedAt,
    this.driverName,
    this.vehicleType,
    this.rating,
  });

  final bool isValid;
  final bool isActive;
  final String verifiedAt;
  final String? driverName;
  final int? vehicleType;
  final double? rating;

  factory BadgeVerifyModel.fromJson(Map<String, dynamic> json) =>
      BadgeVerifyModel(
        isValid: json['isValid'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? false,
        verifiedAt: json['verifiedAt'] as String? ?? '',
        driverName: json['driverName'] as String?,
        vehicleType: parseVehicleType(json['vehicleType']),
        rating: (json['rating'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props =>
      [isValid, isActive, verifiedAt, driverName, vehicleType, rating];
}
