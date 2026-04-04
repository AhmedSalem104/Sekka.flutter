import 'package:equatable/equatable.dart';

class InvoiceSummaryEntity extends Equatable {
  const InvoiceSummaryEntity({
    required this.totalInvoices,
    required this.pendingInvoices,
    required this.paidInvoices,
    required this.overdueInvoices,
    required this.totalEarnings,
    required this.totalCommissions,
    required this.totalNetAmount,
    required this.totalPaid,
    required this.totalOutstanding,
    required this.averageInvoiceAmount,
  });

  final int totalInvoices;
  final int pendingInvoices;
  final int paidInvoices;
  final int overdueInvoices;
  final double totalEarnings;
  final double totalCommissions;
  final double totalNetAmount;
  final double totalPaid;
  final double totalOutstanding;
  final double averageInvoiceAmount;

  Map<String, dynamic> toJson() => {
        'totalInvoices': totalInvoices,
        'pendingInvoices': pendingInvoices,
        'paidInvoices': paidInvoices,
        'overdueInvoices': overdueInvoices,
        'totalEarnings': totalEarnings,
        'totalCommissions': totalCommissions,
        'totalNetAmount': totalNetAmount,
        'totalPaid': totalPaid,
        'totalOutstanding': totalOutstanding,
        'averageInvoiceAmount': averageInvoiceAmount,
      };

  @override
  List<Object?> get props => [totalInvoices, totalNetAmount, totalOutstanding];
}
