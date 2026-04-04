import 'package:equatable/equatable.dart';

sealed class InvoicesEvent extends Equatable {
  const InvoicesEvent();
  @override
  List<Object?> get props => [];
}

final class InvoicesLoadRequested extends InvoicesEvent {
  const InvoicesLoadRequested();
}

final class InvoicesRefreshRequested extends InvoicesEvent {
  const InvoicesRefreshRequested();
}

final class InvoicesFilterChanged extends InvoicesEvent {
  const InvoicesFilterChanged(this.statusFilter);
  final int? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

final class InvoiceDetailRequested extends InvoicesEvent {
  const InvoiceDetailRequested(this.invoiceId);
  final String invoiceId;
  @override
  List<Object?> get props => [invoiceId];
}

final class InvoicePdfDownloadRequested extends InvoicesEvent {
  const InvoicePdfDownloadRequested(this.invoiceId);
  final String invoiceId;
  @override
  List<Object?> get props => [invoiceId];
}

final class InvoicesClearMessage extends InvoicesEvent {
  const InvoicesClearMessage();
}
