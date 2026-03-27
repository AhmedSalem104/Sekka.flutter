import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../domain/entities/daily_settlement_summary_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

// ── Events ──

sealed class SettlementEvent extends Equatable {
  const SettlementEvent();
  @override
  List<Object?> get props => [];
}

final class SettlementsLoadRequested extends SettlementEvent {
  const SettlementsLoadRequested();
}

final class SettlementsNextPage extends SettlementEvent {
  const SettlementsNextPage();
}

final class SettlementCreateRequested extends SettlementEvent {
  const SettlementCreateRequested({
    required this.partnerId,
    required this.amount,
    required this.settlementType,
    this.notes,
    required this.sendWhatsApp,
  });

  final String partnerId;
  final double amount;
  final int settlementType;
  final String? notes;
  final bool sendWhatsApp;

  @override
  List<Object?> get props =>
      [partnerId, amount, settlementType, notes, sendWhatsApp];
}

final class SettlementReceiptUpload extends SettlementEvent {
  const SettlementReceiptUpload({
    required this.settlementId,
    required this.file,
  });

  final String settlementId;
  final File file;

  @override
  List<Object?> get props => [settlementId, file];
}

// ── States ──

sealed class SettlementState extends Equatable {
  const SettlementState();
  @override
  List<Object?> get props => [];
}

final class SettlementInitial extends SettlementState {
  const SettlementInitial();
}

final class SettlementLoading extends SettlementState {
  const SettlementLoading();
}

final class SettlementListLoaded extends SettlementState {
  const SettlementListLoaded({
    required this.settlements,
    required this.summary,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  final List<SettlementEntity> settlements;
  final DailySettlementSummaryEntity summary;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  SettlementListLoaded copyWith({
    List<SettlementEntity>? settlements,
    DailySettlementSummaryEntity? summary,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return SettlementListLoaded(
      settlements: settlements ?? this.settlements,
      summary: summary ?? this.summary,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [settlements, summary, hasMore, currentPage, isLoadingMore];
}

final class SettlementCreating extends SettlementState {
  const SettlementCreating();
}

final class SettlementCreated extends SettlementState {
  const SettlementCreated(this.settlement);
  final SettlementEntity settlement;

  @override
  List<Object?> get props => [settlement];
}

final class SettlementError extends SettlementState {
  const SettlementError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc({required SettlementRepository repository})
      : _repository = repository,
        super(const SettlementInitial()) {
    on<SettlementsLoadRequested>(_onLoad);
    on<SettlementsNextPage>(_onNextPage);
    on<SettlementCreateRequested>(_onCreate);
    on<SettlementReceiptUpload>(_onUploadReceipt);
  }

  final SettlementRepository _repository;

  Future<void> _onLoad(
    SettlementsLoadRequested event,
    Emitter<SettlementState> emit,
  ) async {
    emit(const SettlementLoading());
    try {
      final summary = await _repository.getDailySummary();
      final page = await _repository.getSettlements(pageNumber: 1);

      emit(SettlementListLoaded(
        settlements: page.items.cast<SettlementEntity>(),
        summary: summary,
        hasMore: page.hasNextPage,
        currentPage: 1,
      ));
    } on ApiException catch (e) {
      emit(SettlementError(e.message));
    }
  }

  Future<void> _onNextPage(
    SettlementsNextPage event,
    Emitter<SettlementState> emit,
  ) async {
    final current = state;
    if (current is! SettlementListLoaded ||
        !current.hasMore ||
        current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final page = await _repository.getSettlements(pageNumber: nextPage);

      emit(current.copyWith(
        settlements: [
          ...current.settlements,
          ...page.items.cast<SettlementEntity>(),
        ],
        hasMore: page.hasNextPage,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onCreate(
    SettlementCreateRequested event,
    Emitter<SettlementState> emit,
  ) async {
    emit(const SettlementCreating());
    try {
      final settlement = await _repository.createSettlement(
        partnerId: event.partnerId,
        amount: event.amount,
        settlementType: event.settlementType,
        notes: event.notes,
        sendWhatsApp: event.sendWhatsApp,
      );
      emit(SettlementCreated(settlement));
    } on ApiException catch (e) {
      emit(SettlementError(e.message));
    }
  }

  Future<void> _onUploadReceipt(
    SettlementReceiptUpload event,
    Emitter<SettlementState> emit,
  ) async {
    try {
      await _repository.uploadReceipt(event.settlementId, event.file);
    } on ApiException catch (e) {
      emit(SettlementError(e.message));
    }
  }
}
