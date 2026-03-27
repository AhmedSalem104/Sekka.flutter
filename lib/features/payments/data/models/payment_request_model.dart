import '../../domain/entities/payment_request_entity.dart';

class PaymentRequestModel extends PaymentRequestEntity {
  const PaymentRequestModel({
    required super.id,
    required super.planId,
    required super.planName,
    super.planDescription,
    required super.amount,
    required super.paymentMethod,
    required super.paymentMethodName,
    super.senderPhone,
    super.senderName,
    super.notes,
    required super.status,
    required super.statusName,
    required super.statusNameAr,
    super.proofImageUrl,
    super.rejectionReason,
    super.reviewedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestModel(
      id: json['id'] as String,
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      planDescription: json['planDescription'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as int? ?? 0,
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      senderPhone: json['senderPhone'] as String?,
      senderName: json['senderName'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as int? ?? 0,
      statusName: json['statusName'] as String? ?? '',
      statusNameAr: json['statusNameAr'] as String? ?? '',
      proofImageUrl: json['proofImageUrl'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
