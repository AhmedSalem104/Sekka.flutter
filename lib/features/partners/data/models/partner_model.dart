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

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      partnerType: json['partnerType'] as int? ?? 0,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      commissionType: json['commissionType'] as int? ?? 0,
      commissionValue: (json['commissionValue'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] as String? ?? '#FC5D01',
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      verificationStatus: json['verificationStatus'] as int? ?? 0,
    );
  }
}
