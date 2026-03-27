class PartnerOrderModel {
  const PartnerOrderModel({
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.total,
    this.customerName,
    this.deliveryAddress,
    this.driverName,
  });

  final String orderId;
  final DateTime orderDate;
  final String status;
  final double total;
  final String? customerName;
  final String? deliveryAddress;
  final String? driverName;

  factory PartnerOrderModel.fromJson(Map<String, dynamic> json) {
    return PartnerOrderModel(
      orderId: json['orderId'] as String,
      orderDate: DateTime.parse(
        json['orderDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customerName'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      driverName: json['driverName'] as String?,
    );
  }
}
