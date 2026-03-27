class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.phone,
    this.name,
    required this.averageRating,
    required this.totalDeliveries,
    required this.successfulDeliveries,
    required this.isBlocked,
    this.lastDeliveryDate,
  });

  final String id;
  final String phone;
  final String? name;
  final double averageRating;
  final int totalDeliveries;
  final int successfulDeliveries;
  final bool isBlocked;
  final DateTime? lastDeliveryDate;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: json['totalDeliveries'] as int? ?? 0,
      successfulDeliveries: json['successfulDeliveries'] as int? ?? 0,
      isBlocked: json['isBlocked'] as bool? ?? false,
      lastDeliveryDate: json['lastDeliveryDate'] != null
          ? DateTime.parse(json['lastDeliveryDate'] as String)
          : null,
    );
  }
}
