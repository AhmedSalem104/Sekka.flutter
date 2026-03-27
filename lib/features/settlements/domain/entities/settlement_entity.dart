import 'package:equatable/equatable.dart';

class SettlementEntity extends Equatable {
  const SettlementEntity({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.amount,
    required this.settlementType,
    required this.settlementTypeName,
    this.notes,
    this.receiptImageUrl,
    required this.whatsAppSent,
    required this.createdAt,
  });

  final String id;
  final String partnerId;
  final String partnerName;
  final double amount;
  final int settlementType;
  final String settlementTypeName;
  final String? notes;
  final String? receiptImageUrl;
  final bool whatsAppSent;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, amount, settlementType, createdAt];
}
