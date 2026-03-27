import 'package:equatable/equatable.dart';

class InvoiceEntity extends Equatable {
  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.totalOrders,
    required this.totalEarnings,
    required this.totalCommissions,
    required this.totalExpenses,
    required this.netAmount,
    required this.status,
    required this.statusName,
    required this.statusNameAr,
    required this.issuedAt,
    required this.dueDate,
    this.paidAt,
    this.lineItems = const [],
  });

  final String id;
  final String invoiceNumber;
  final String periodStart;
  final String periodEnd;
  final int totalOrders;
  final double totalEarnings;
  final double totalCommissions;
  final double totalExpenses;
  final double netAmount;
  final int status;
  final String statusName;
  final String statusNameAr;
  final DateTime issuedAt;
  final String dueDate;
  final DateTime? paidAt;
  final List<InvoiceLineItem> lineItems;

  @override
  List<Object?> get props => [id, invoiceNumber, netAmount, status];
}

class InvoiceLineItem extends Equatable {
  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.type,
  });

  final String description;
  final double quantity;
  final double unitPrice;
  final double total;
  final String type;

  @override
  List<Object?> get props => [description, total, type];
}
