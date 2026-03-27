import '../../domain/entities/invoice_summary_entity.dart';

class InvoiceSummaryModel extends InvoiceSummaryEntity {
  const InvoiceSummaryModel({
    required super.totalInvoices,
    required super.pendingInvoices,
    required super.paidInvoices,
    required super.overdueInvoices,
    required super.totalEarnings,
    required super.totalCommissions,
    required super.totalNetAmount,
    required super.totalPaid,
    required super.totalOutstanding,
    required super.averageInvoiceAmount,
  });

  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryModel(
      totalInvoices: json['totalInvoices'] as int? ?? 0,
      pendingInvoices: json['pendingInvoices'] as int? ?? 0,
      paidInvoices: json['paidInvoices'] as int? ?? 0,
      overdueInvoices: json['overdueInvoices'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0,
      totalNetAmount: (json['totalNetAmount'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      totalOutstanding: (json['totalOutstanding'] as num?)?.toDouble() ?? 0,
      averageInvoiceAmount:
          (json['averageInvoiceAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
