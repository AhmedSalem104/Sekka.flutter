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

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'totalOrders': totalOrders,
        'totalEarnings': totalEarnings,
        'totalCommissions': totalCommissions,
        'totalExpenses': totalExpenses,
        'netAmount': netAmount,
        'status': status,
        'statusName': statusName,
        'statusNameAr': statusNameAr,
        'issuedAt': issuedAt.toIso8601String(),
        'dueDate': dueDate,
        'paidAt': paidAt?.toIso8601String(),
        'lineItems': lineItems.map((e) => e.toJson()).toList(),
      };

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

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
        'type': type,
      };

  @override
  List<Object?> get props => [description, total, type];
}
