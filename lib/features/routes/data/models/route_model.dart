import '../../../../shared/utils/safe_parse.dart';

class RouteOrderModel {
  const RouteOrderModel({
    required this.orderId,
    required this.sequenceIndex,
    this.orderNumber,
    this.customerName,
    this.deliveryAddress = '',
    this.amount = 0,
    this.status = 0,
    this.estimatedArrivalMinutes,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'sequenceIndex': sequenceIndex,
        'orderNumber': orderNumber,
        'customerName': customerName,
        'deliveryAddress': deliveryAddress,
        'amount': amount,
        'status': status,
        'estimatedArrivalMinutes': estimatedArrivalMinutes,
      };

  factory RouteOrderModel.fromJson(Map<String, dynamic> json) {
    return RouteOrderModel(
      orderId: json['orderId'] as String? ?? '',
      sequenceIndex: json['sequenceIndex'] as int? ?? 0,
      orderNumber: json['orderNumber'] as String?,
      customerName: json['customerName'] as String?,
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: parseRouteStatus(json['status']),
      estimatedArrivalMinutes: json['estimatedArrivalMinutes'] as int?,
    );
  }

  final String orderId;
  final int sequenceIndex;
  final String? orderNumber;
  final String? customerName;
  final String deliveryAddress;
  final double amount;
  final int status;
  final int? estimatedArrivalMinutes;
}

class RouteModel {
  const RouteModel({
    required this.id,
    this.orders = const [],
    this.estimatedTimeMinutes = 0,
    this.totalDistanceKm = 0,
    this.efficiencyScore,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'orders': orders.map((o) => o.toJson()).toList(),
        'estimatedTimeMinutes': estimatedTimeMinutes,
        'totalDistanceKm': totalDistanceKm,
        'efficiencyScore': efficiencyScore,
        'isActive': isActive,
      };

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String? ?? '',
      orders: ((json['orders'] as List<dynamic>?)
              ?.map(
                  (e) => RouteOrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [])
            ..sort((a, b) => a.sequenceIndex.compareTo(b.sequenceIndex)),
      estimatedTimeMinutes: json['estimatedTimeMinutes'] as int? ?? 0,
      totalDistanceKm:
          (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      efficiencyScore: json['efficiencyScore'] as int?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  final String id;
  final List<RouteOrderModel> orders;
  final int estimatedTimeMinutes;
  final double totalDistanceKm;
  final int? efficiencyScore;
  final bool isActive;
}
