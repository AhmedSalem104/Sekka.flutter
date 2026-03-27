import 'package:sekka/features/customers/data/models/address_model.dart';
import 'package:sekka/features/customers/data/models/customer_order_model.dart';
import 'package:sekka/features/customers/data/models/customer_rating_model.dart';

class CustomerDetailModel {
  const CustomerDetailModel({
    required this.id,
    required this.phone,
    this.name,
    required this.averageRating,
    required this.totalDeliveries,
    required this.successfulDeliveries,
    required this.isBlocked,
    this.lastDeliveryDate,
    required this.addresses,
    required this.recentOrders,
    required this.ratings,
  });

  final String id;
  final String phone;
  final String? name;
  final double averageRating;
  final int totalDeliveries;
  final int successfulDeliveries;
  final bool isBlocked;
  final DateTime? lastDeliveryDate;
  final List<AddressModel> addresses;
  final List<CustomerOrderModel> recentOrders;
  final List<CustomerRatingModel> ratings;

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailModel(
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
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentOrders: (json['recentOrders'] as List<dynamic>?)
              ?.map((e) =>
                  CustomerOrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ratings: (json['ratings'] as List<dynamic>?)
              ?.map((e) =>
                  CustomerRatingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
