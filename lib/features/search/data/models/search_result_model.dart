import '../../../../shared/utils/safe_parse.dart';

class SearchResultModel {
  const SearchResultModel({
    required this.orders,
    required this.customers,
    required this.partners,
    required this.totalResults,
  });

  final List<SearchOrderItem> orders;
  final List<SearchCustomerItem> customers;
  final List<SearchPartnerItem> partners;
  final int totalResults;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      orders: (json['orders'] as List<dynamic>?)
              ?.map(
                (e) => SearchOrderItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      customers: (json['customers'] as List<dynamic>?)
              ?.map(
                (e) => SearchCustomerItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      partners: (json['partners'] as List<dynamic>?)
              ?.map(
                (e) => SearchPartnerItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalResults: json['totalResults'] as int? ?? 0,
    );
  }

  bool get isEmpty => totalResults == 0;
}

class SearchOrderItem {
  const SearchOrderItem({
    required this.id,
    required this.orderNumber,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double amount;
  final int status;
  final DateTime? createdAt;

  factory SearchOrderItem.fromJson(Map<String, dynamic> json) {
    return SearchOrderItem(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: parseOrderStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class SearchCustomerItem {
  const SearchCustomerItem({
    required this.id,
    required this.phone,
    this.name,
    this.averageRating,
    this.totalDeliveries,
  });

  final String id;
  final String phone;
  final String? name;
  final double? averageRating;
  final int? totalDeliveries;

  factory SearchCustomerItem.fromJson(Map<String, dynamic> json) {
    return SearchCustomerItem(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalDeliveries: json['totalDeliveries'] as int?,
    );
  }
}

class SearchPartnerItem {
  const SearchPartnerItem({
    required this.id,
    required this.name,
    this.partnerType,
    this.phone,
    this.color,
  });

  final String id;
  final String name;
  final int? partnerType;
  final String? phone;
  final String? color;

  factory SearchPartnerItem.fromJson(Map<String, dynamic> json) {
    return SearchPartnerItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      partnerType: json['partnerType'] != null ? parsePartnerType(json['partnerType']) : null,
      phone: json['phone'] as String?,
      color: json['color'] as String?,
    );
  }
}
