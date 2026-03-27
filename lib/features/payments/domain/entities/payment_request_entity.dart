import 'package:equatable/equatable.dart';

class PaymentRequestEntity extends Equatable {
  const PaymentRequestEntity({
    required this.id,
    required this.planId,
    required this.planName,
    this.planDescription,
    required this.amount,
    required this.paymentMethod,
    required this.paymentMethodName,
    this.senderPhone,
    this.senderName,
    this.notes,
    required this.status,
    required this.statusName,
    required this.statusNameAr,
    this.proofImageUrl,
    this.rejectionReason,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String planId;
  final String planName;
  final String? planDescription;
  final double amount;
  final int paymentMethod;
  final String paymentMethodName;
  final String? senderPhone;
  final String? senderName;
  final String? notes;
  final int status;
  final String statusName;
  final String statusNameAr;
  final String? proofImageUrl;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, amount, status, createdAt];
}
