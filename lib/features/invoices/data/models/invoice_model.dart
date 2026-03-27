import '../../domain/entities/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.periodStart,
    required super.periodEnd,
    required super.totalOrders,
    required super.totalEarnings,
    required super.totalCommissions,
    required super.totalExpenses,
    required super.netAmount,
    required super.status,
    required super.statusName,
    required super.statusNameAr,
    required super.issuedAt,
    required super.dueDate,
    super.paidAt,
    super.lineItems,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as int? ?? 0,
      statusName: json['statusName'] as String? ?? '',
      statusNameAr: json['statusNameAr'] as String? ?? '',
      issuedAt: DateTime.parse(
        json['issuedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      dueDate: json['dueDate'] as String? ?? '',
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      lineItems: (json['lineItems'] as List?)
              ?.map((e) =>
                  InvoiceLineItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class InvoiceLineItemModel extends InvoiceLineItem {
  const InvoiceLineItemModel({
    required super.description,
    required super.quantity,
    required super.unitPrice,
    required super.total,
    required super.type,
  });

  factory InvoiceLineItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItemModel(
      description: json['description'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? '',
    );
  }
}
