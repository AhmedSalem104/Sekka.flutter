import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/invoice_summary_model.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_summary_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import 'invoices_event.dart';
import 'invoices_state.dart';

class InvoicesBloc extends HydratedBloc<InvoicesEvent, InvoicesState> {
  InvoicesBloc({required InvoiceRepository repository})
      : _repository = repository,
        super(const InvoicesInitial()) {
    on<InvoicesLoadRequested>(_onLoadRequested);
    on<InvoicesRefreshRequested>(_onRefreshRequested);
    on<InvoicesFilterChanged>(_onFilterChanged);
    on<InvoiceDetailRequested>(_onDetailRequested);
    on<InvoicePdfDownloadRequested>(_onPdfDownloadRequested);
    on<InvoicesClearMessage>(_onClearMessage);
  }

  final InvoiceRepository _repository;

  Future<void> _onLoadRequested(
    InvoicesLoadRequested event,
    Emitter<InvoicesState> emit,
  ) async {
    if (state is! InvoicesLoaded) {
      emit(const InvoicesLoading());
    }

    try {
      final results = await Future.wait([
        _repository.getInvoices(),
        _repository.getInvoiceSummary(),
      ]);

      final invoices = results[0] as List<InvoiceEntity>;
      final summary = results[1] as InvoiceSummaryEntity;

      emit(InvoicesLoaded(
        invoices: invoices,
        summary: summary,
      ));
    } on ApiException catch (e) {
      if (state is! InvoicesLoaded) {
        emit(InvoicesError(e.message));
      }
    }
  }

  Future<void> _onRefreshRequested(
    InvoicesRefreshRequested event,
    Emitter<InvoicesState> emit,
  ) async {
    try {
      final current = state;
      final statusFilter =
          current is InvoicesLoaded ? current.statusFilter : null;

      final results = await Future.wait([
        _repository.getInvoices(status: statusFilter),
        _repository.getInvoiceSummary(),
      ]);

      final invoices = results[0] as List<InvoiceEntity>;
      final summary = results[1] as InvoiceSummaryEntity;

      emit(InvoicesLoaded(
        invoices: invoices,
        summary: summary,
        statusFilter: statusFilter,
      ));
    } on ApiException {
      // Keep cached state on refresh failure
    }
  }

  Future<void> _onFilterChanged(
    InvoicesFilterChanged event,
    Emitter<InvoicesState> emit,
  ) async {
    final current = state;
    if (current is! InvoicesLoaded) return;

    emit(current.copyWith(
      statusFilter: () => event.statusFilter,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getInvoices(
        status: event.statusFilter,
      );

      emit(current.copyWith(
        invoices: result,
        statusFilter: () => event.statusFilter,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onDetailRequested(
    InvoiceDetailRequested event,
    Emitter<InvoicesState> emit,
  ) async {
    final current = state;
    if (current is! InvoicesLoaded) return;

    try {
      final invoice = await _repository.getInvoiceDetail(event.invoiceId);
      emit(current.copyWith(
        selectedInvoice: () => invoice,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        actionMessage: () => e.message,
        isActionError: true,
      ));
    }
  }

  Future<void> _onPdfDownloadRequested(
    InvoicePdfDownloadRequested event,
    Emitter<InvoicesState> emit,
  ) async {
    final current = state;
    if (current is! InvoicesLoaded) return;

    emit(current.copyWith(isDownloading: true));

    try {
      final bytes = await _repository.downloadInvoicePdf(event.invoiceId);
      emit(current.copyWith(
        isDownloading: false,
        pdfBytes: () => bytes,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isDownloading: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    }
  }

  void _onClearMessage(
    InvoicesClearMessage event,
    Emitter<InvoicesState> emit,
  ) {
    final current = state;
    if (current is InvoicesLoaded) {
      emit(current.copyWith(
        actionMessage: () => null,
        isActionError: false,
        pdfBytes: () => null,
      ));
    }
  }

  // ── Hydration ──

  @override
  InvoicesState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final invoices = (json['invoices'] as List<dynamic>)
            .map((e) => InvoiceModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();
        final summary = InvoiceSummaryModel.fromJson(
          Map<String, dynamic>.from(json['summary'] as Map),
        );
        return InvoicesLoaded(
          invoices: invoices,
          summary: summary,
          hasMore: json['hasMore'] as bool? ?? false,
          currentPage: json['currentPage'] as int? ?? 1,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(InvoicesState state) {
    if (state is InvoicesLoaded) {
      return {
        'type': 'loaded',
        'invoices': state.invoices.map((e) => e.toJson()).toList(),
        'summary': state.summary.toJson(),
        'hasMore': state.hasMore,
        'currentPage': state.currentPage,
      };
    }
    return null;
  }
}
