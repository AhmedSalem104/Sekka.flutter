import '../../../../shared/utils/safe_parse.dart';

class PartnerModel {
  const PartnerModel({
    required this.id,
    required this.name,
    required this.partnerType,
    this.phone,
    this.address,
    required this.commissionType,
    required this.commissionValue,
    required this.color,
    this.logoUrl,
    required this.isActive,
    required this.verificationStatus,
  });

  final String id;
  final String name;
  final int partnerType;
  final String? phone;
  final String? address;
  final int commissionType;
  final double commissionValue;
  final String color;
  final String? logoUrl;
  final bool isActive;
  final int verificationStatus;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'partnerType': partnerType,
        'phone': phone,
        'address': address,
        'commissionType': commissionType,
        'commissionValue': commissionValue,
        'color': color,
        'logoUrl': logoUrl,
        'isActive': isActive,
        'verificationStatus': verificationStatus,
      };

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      partnerType: parsePartnerType(json['partnerType']),
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      commissionType: parseCommissionType(json['commissionType']),
      commissionValue: (json['commissionValue'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] as String? ?? '#FC5D01',
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      verificationStatus: parseVerificationStatus(json['verificationStatus']),
    );
  }
}
