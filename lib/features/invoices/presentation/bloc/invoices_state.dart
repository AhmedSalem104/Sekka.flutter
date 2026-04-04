import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_summary_entity.dart';

sealed class InvoicesState extends Equatable {
  const InvoicesState();
  @override
  List<Object?> get props => [];
}

final class InvoicesInitial extends InvoicesState {
  const InvoicesInitial();
}

final class InvoicesLoading extends InvoicesState {
  const InvoicesLoading();
}

final class InvoicesLoaded extends InvoicesState {
  const InvoicesLoaded({
    required this.invoices,
    required this.summary,
    this.statusFilter,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.selectedInvoice,
    this.isDownloading = false,
    this.actionMessage,
    this.isActionError = false,
    this.pdfBytes,
  });

  final List<InvoiceEntity> invoices;
  final InvoiceSummaryEntity summary;
  final int? statusFilter;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final InvoiceEntity? selectedInvoice;
  final bool isDownloading;
  final String? actionMessage;
  final bool isActionError;
  final List<int>? pdfBytes;

  InvoicesLoaded copyWith({
    List<InvoiceEntity>? invoices,
    InvoiceSummaryEntity? summary,
    int? Function()? statusFilter,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    InvoiceEntity? Function()? selectedInvoice,
    bool? isDownloading,
    String? Function()? actionMessage,
    bool? isActionError,
    List<int>? Function()? pdfBytes,
  }) {
    return InvoicesLoaded(
      invoices: invoices ?? this.invoices,
      summary: summary ?? this.summary,
      statusFilter:
          statusFilter != null ? statusFilter() : this.statusFilter,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedInvoice: selectedInvoice != null
          ? selectedInvoice()
          : this.selectedInvoice,
      isDownloading: isDownloading ?? this.isDownloading,
      actionMessage:
          actionMessage != null ? actionMessage() : this.actionMessage,
      isActionError: isActionError ?? this.isActionError,
      pdfBytes: pdfBytes != null ? pdfBytes() : this.pdfBytes,
    );
  }

  @override
  List<Object?> get props => [
        invoices,
        summary,
        statusFilter,
        hasMore,
        currentPage,
        isLoadingMore,
        selectedInvoice,
        isDownloading,
        actionMessage,
        isActionError,
        pdfBytes,
      ];
}

final class InvoicesError extends InvoicesState {
  const InvoicesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
