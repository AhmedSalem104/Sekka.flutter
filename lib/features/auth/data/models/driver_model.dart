import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.profileImageUrl,
    super.licenseImageUrl,
    required super.vehicleType,
    super.isOnline,
    super.cashOnHand,
    super.totalPoints,
    super.level,
    required super.joinedAt,
    super.referralCode,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      licenseImageUrl: json['licenseImageUrl'] as String?,
      vehicleType: json['vehicleType'] as int,
      isOnline: json['isOnline'] as bool? ?? false,
      cashOnHand: (json['cashOnHand'] as num?)?.toDouble() ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      referralCode: json['referralCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'licenseImageUrl': licenseImageUrl,
        'vehicleType': vehicleType,
        'isOnline': isOnline,
        'cashOnHand': cashOnHand,
        'totalPoints': totalPoints,
        'level': level,
        'joinedAt': joinedAt.toIso8601String(),
        'referralCode': referralCode,
      };
}
