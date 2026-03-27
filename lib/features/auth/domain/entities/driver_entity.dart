import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  const DriverEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImageUrl,
    this.licenseImageUrl,
    required this.vehicleType,
    this.isOnline = false,
    this.cashOnHand = 0,
    this.totalPoints = 0,
    this.level = 0,
    required this.joinedAt,
    this.referralCode,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final String? licenseImageUrl;
  final int vehicleType;
  final bool isOnline;
  final double cashOnHand;
  final int totalPoints;
  final int level;
  final DateTime joinedAt;
  final String? referralCode;

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        profileImageUrl,
        licenseImageUrl,
        vehicleType,
        isOnline,
        cashOnHand,
        totalPoints,
        level,
        joinedAt,
        referralCode,
      ];
}
