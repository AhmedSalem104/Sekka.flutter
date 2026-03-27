class CreatePartnerModel {
  const CreatePartnerModel({
    required this.name,
    required this.partnerType,
    this.phone,
    this.address,
    required this.commissionType,
    required this.commissionValue,
    required this.defaultPaymentMethod,
    this.color,
    this.receiptHeader,
  });

  final String name;
  final int partnerType;
  final String? phone;
  final String? address;
  final int commissionType;
  final double commissionValue;
  final int defaultPaymentMethod;
  final String? color;
  final String? receiptHeader;

  factory CreatePartnerModel.fromJson(Map<String, dynamic> json) {
    return CreatePartnerModel(
      name: json['name'] as String,
      partnerType: json['partnerType'] as int? ?? 0,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      commissionType: json['commissionType'] as int? ?? 0,
      commissionValue: (json['commissionValue'] as num?)?.toDouble() ?? 0.0,
      defaultPaymentMethod: json['defaultPaymentMethod'] as int? ?? 0,
      color: json['color'] as String?,
      receiptHeader: json['receiptHeader'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'partnerType': partnerType,
      'commissionType': commissionType,
      'commissionValue': commissionValue,
      'defaultPaymentMethod': defaultPaymentMethod,
    };

    if (phone != null) json['phone'] = phone;
    if (address != null) json['address'] = address;
    if (color != null) json['color'] = color;
    if (receiptHeader != null) json['receiptHeader'] = receiptHeader;

    return json;
  }
}
