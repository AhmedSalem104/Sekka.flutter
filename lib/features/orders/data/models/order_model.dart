import '../../../../shared/utils/safe_parse.dart';
import '../../../../shared/enums/order_enums.dart';

class OrderPhotoModel {
  const OrderPhotoModel({
    required this.id,
    required this.photoUrl,
    required this.photoType,
    this.takenAt,
  });

  final String id;
  final String photoUrl;
  final int photoType;
  final DateTime? takenAt;

  factory OrderPhotoModel.fromJson(Map<String, dynamic> json) {
    return OrderPhotoModel(
      id: json['id'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      photoType: safeInt(json['photoType'], 0),
      takenAt: json['takenAt'] != null
          ? DateTime.tryParse(json['takenAt'] as String)
          : null,
    );
  }

  /// Full URL using base domain.
  String get fullUrl => 'https://sekka.runasp.net$photoUrl';

  String get typeLabel => switch (photoType) {
        0 => 'إثبات التسليم',
        1 => 'صورة الشحنة',
        2 => 'صورة التلف',
        3 => 'صورة الفاتورة',
        4 => 'التوقيع',
        5 => 'صورة المكان',
        _ => 'صورة',
      };
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.customerName,
    this.customerPhone,
    this.partnerName,
    this.partnerColor,
    this.description,
    required this.amount,
    this.commissionAmount,
    required this.paymentMethod,
    required this.status,
    required this.priority,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.distanceKm,
    this.sequenceIndex,
    this.worthScore,
    this.notes,
    this.itemCount,
    this.timeWindowStart,
    this.timeWindowEnd,
    this.scheduledDate,
    required this.createdAt,
    this.deliveredAt,
    this.photos = const [],
    this.isRecurring = false,
    this.recurrencePattern,
    this.isPaused = false,
    this.nextScheduledDate,
    this.totalOccurrences,
    this.trackingCode,
  });

  final String id;
  final String orderNumber;
  final String? customerName;
  final String? customerPhone;
  final String? partnerName;
  final String? partnerColor;
  final String? description;
  final double amount;
  final double? commissionAmount;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final OrderPriority priority;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final double? distanceKm;
  final int? sequenceIndex;
  final double? worthScore;
  final String? notes;
  final int? itemCount;
  final DateTime? timeWindowStart;
  final DateTime? timeWindowEnd;
  final String? scheduledDate;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final List<OrderPhotoModel> photos;
  final bool isRecurring;
  final String? recurrencePattern;
  final bool isPaused;
  final String? nextScheduledDate;
  final int? totalOccurrences;
  final String? trackingCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'partnerName': partnerName,
        'partnerColor': partnerColor,
        'description': description,
        'amount': amount,
        'commissionAmount': commissionAmount,
        'paymentMethod': paymentMethod.value,
        'status': status.value,
        'priority': priority.value,
        'pickupAddress': pickupAddress,
        'pickupLatitude': pickupLatitude,
        'pickupLongitude': pickupLongitude,
        'deliveryAddress': deliveryAddress,
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
        'distanceKm': distanceKm,
        'sequenceIndex': sequenceIndex,
        'worthScore': worthScore,
        'notes': notes,
        'itemCount': itemCount,
        'timeWindowStart': timeWindowStart?.toIso8601String(),
        'timeWindowEnd': timeWindowEnd?.toIso8601String(),
        'scheduledDate': scheduledDate,
        'createdAt': createdAt.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'photos': photos.map((p) => {
              'id': p.id,
              'photoUrl': p.photoUrl,
              'photoType': p.photoType,
              'takenAt': p.takenAt?.toIso8601String(),
            }).toList(),
        'isRecurring': isRecurring,
        'recurrencePattern': recurrencePattern,
        'isPaused': isPaused,
        'nextScheduledDate': nextScheduledDate,
        'totalOccurrences': totalOccurrences,
        'trackingCode': trackingCode,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      partnerName: json['partnerName'] as String?,
      partnerColor: json['partnerColor'] as String?,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      paymentMethod: PaymentMethod.fromValue(parsePaymentMethod(json['paymentMethod'])),
      status: OrderStatus.fromValue(parseOrderStatus(json['status'])),
      priority: OrderPriority.fromValue(parseOrderPriority(json['priority'])),
      pickupAddress: json['pickupAddress'] as String?,
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble(),
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      sequenceIndex: json['sequenceIndex'] is int ? json['sequenceIndex'] as int : (json['sequenceIndex'] is String ? int.tryParse(json['sequenceIndex'] as String) : null),
      worthScore: (json['worthScore'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      itemCount: json['itemCount'] is int ? json['itemCount'] as int : (json['itemCount'] is String ? int.tryParse(json['itemCount'] as String) : null),
      timeWindowStart: json['timeWindowStart'] != null
          ? DateTime.tryParse(json['timeWindowStart'] as String)
          : null,
      timeWindowEnd: json['timeWindowEnd'] != null
          ? DateTime.tryParse(json['timeWindowEnd'] as String)
          : null,
      scheduledDate: json['scheduledDate'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) =>
                  OrderPhotoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrencePattern: json['recurrencePattern'] as String?,
      isPaused: json['isPaused'] as bool? ?? false,
      nextScheduledDate: json['nextScheduledDate'] as String?,
      totalOccurrences: json['totalOccurrences'] is int ? json['totalOccurrences'] as int : (json['totalOccurrences'] is String ? int.tryParse(json['totalOccurrences'] as String) : null),
      trackingCode: json['trackingCode'] as String?,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    String? pickupAddress,
    String? description,
    String? notes,
    OrderStatus? status,
    DateTime? deliveredAt,
    List<OrderPhotoModel>? photos,
    bool? isPaused,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      partnerName: partnerName,
      partnerColor: partnerColor,
      description: description ?? this.description,
      amount: amount,
      commissionAmount: commissionAmount,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      priority: priority,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      distanceKm: distanceKm,
      sequenceIndex: sequenceIndex,
      worthScore: worthScore,
      notes: notes ?? this.notes,
      itemCount: itemCount,
      timeWindowStart: timeWindowStart,
      timeWindowEnd: timeWindowEnd,
      scheduledDate: scheduledDate,
      createdAt: createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      photos: photos ?? this.photos,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      isPaused: isPaused ?? this.isPaused,
      nextScheduledDate: nextScheduledDate,
      totalOccurrences: totalOccurrences,
      trackingCode: trackingCode,
    );
  }

  /// Create from recurring orders list endpoint (Map<String, dynamic>).
  factory OrderModel.fromRecurringMap(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.fromValue(parsePaymentMethod(json['paymentMethod'])),
      status: OrderStatus.fromValue(parseOrderStatus(json['status'])),
      priority: OrderPriority.fromValue(parseOrderPriority(json['priority'])),
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isRecurring: true,
      recurrencePattern: json['recurrencePattern'] as String?,
      isPaused: json['isPaused'] as bool? ?? false,
      nextScheduledDate: json['nextScheduledDate'] as String?,
      totalOccurrences: json['totalOccurrences'] is int ? json['totalOccurrences'] as int : (json['totalOccurrences'] is String ? int.tryParse(json['totalOccurrences'] as String) : null),
    );
  }

  /// Minimal payload for creating/updating an order on the server.
  Map<String, dynamic> toCreateJson() => {
        if (customerName != null) 'customerName': customerName,
        if (customerPhone != null) 'customerPhone': customerPhone,
        if (description != null) 'description': description,
        'amount': amount,
        'paymentMethod': paymentMethod.value,
        'priority': priority.value,
        if (pickupAddress != null) 'pickupAddress': pickupAddress,
        if (pickupLatitude != null) 'pickupLatitude': pickupLatitude,
        if (pickupLongitude != null) 'pickupLongitude': pickupLongitude,
        'deliveryAddress': deliveryAddress,
        if (deliveryLatitude != null) 'deliveryLatitude': deliveryLatitude,
        if (deliveryLongitude != null) 'deliveryLongitude': deliveryLongitude,
        if (notes != null) 'notes': notes,
        if (itemCount != null) 'itemCount': itemCount,
        if (scheduledDate != null) 'scheduledDate': scheduledDate,
      };
}
