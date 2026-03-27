class CustomerOrderModel {
  const CustomerOrderModel({
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.total,
    this.pickupAddress,
    this.deliveryAddress,
  });

  final String orderId;
  final DateTime orderDate;
  final String status;
  final double total;
  final String? pickupAddress;
  final String? deliveryAddress;

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderModel(
      orderId: json['orderId'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      status: json['status'] as String,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      pickupAddress: json['pickupAddress'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
    );
  }
}
