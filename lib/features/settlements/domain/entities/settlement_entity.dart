import 'package:equatable/equatable.dart';

class SettlementEntity extends Equatable {
  const SettlementEntity({
    required this.id,
    required this.driverId,
    required this.partnerId,
    this.partnerName,
    required this.amount,
    required this.settlementType,
    required this.orderCount,
    this.notes,
    this.receiptImageUrl,
    required this.whatsAppSent,
    required this.settledAt,
    required this.createdAt,
  });

  final String id;
  final String driverId;
  final String partnerId;
  final String? partnerName;
  final double amount;
  final int settlementType;
  final int orderCount;
  final String? notes;
  final String? receiptImageUrl;
  final bool whatsAppSent;
  final DateTime settledAt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, amount, settlementType, createdAt];
}
