import 'package:equatable/equatable.dart';

class BadgeModel extends Equatable {
  const BadgeModel({
    required this.driverName,
    required this.driverId,
    required this.vehicleType,
    required this.averageRating,
    required this.totalDeliveries,
    required this.memberSince,
    required this.level,
    required this.qrCodeToken,
    required this.isVerified,
    this.profileImageUrl,
  });

  final String driverName;
  final String driverId;
  final int vehicleType;
  final double averageRating;
  final int totalDeliveries;
  final String memberSince;
  final int level;
  final String qrCodeToken;
  final bool isVerified;
  final String? profileImageUrl;

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
        driverName: json['driverName'] as String? ?? '',
        driverId: json['driverId'] as String? ?? '',
        vehicleType: json['vehicleType'] as int? ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalDeliveries: json['totalDeliveries'] as int? ?? 0,
        memberSince: json['memberSince'] as String? ?? '',
        level: json['level'] as int? ?? 1,
        qrCodeToken: json['qrCodeToken'] as String? ?? '',
        isVerified: json['isVerified'] as bool? ?? false,
        profileImageUrl: json['profileImageUrl'] as String?,
      );

  @override
  List<Object?> get props => [
        driverName,
        driverId,
        vehicleType,
        averageRating,
        totalDeliveries,
        memberSince,
        level,
        qrCodeToken,
        isVerified,
        profileImageUrl,
      ];
}
