import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_result.dart';
import '../../../partners/data/models/create_partner_model.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../../partners/data/repositories/partner_repository.dart';
import '../../domain/entities/daily_settlement_summary_entity.dart';
import '../../domain/entities/partner_balance_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

part 'settlement_event.dart';
part 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc({
    required SettlementRepository repository,
    required PartnerRepository partnerRepository,
  })  : _repository = repository,
        _partnerRepository = partnerRepository,
        super(const SettlementInitial()) {
    on<SettlementsLoadRequested>(_onLoad);
    on<SettlementsNextPage>(_onNextPage);
    on<SettlementRefreshRequested>(_onRefresh);
    on<SettlementCreateRequested>(_onCreate);
    on<SettlementReceiptUpload>(_onUploadReceipt);
    on<SettlementFilterChanged>(_onFilterChanged);
    on<PartnerBalanceRequested>(_onPartnerBalance);
    on<PartnerCreateRequested>(_onCreatePartner);
  }

  final SettlementRepository _repository;
  final PartnerRepository _partnerRepository;

  Future<void> _onLoad(
    SettlementsLoadRequested event,
    Emitter<SettlementState> emit,
  ) async {
    emit(const SettlementLoading());
    try {
      final results = await Future.wait([
        _repository.getDailySummary(),
        _repository.getSettlements(page: 1),
        _partnerRepository.getPartners(),
      ]);

      final summary = results[0] as DailySettlementSummaryEntity;
      final settlements = results[1] as List<SettlementEntity>;
      final partnersResult = results[2];

      // Extract partner list from ApiResult
      final partners = _extractPartners(partnersResult);

      emit(SettlementLoaded(
        summary: summary,
        settlements: settlements,
        partners: partners,
        hasMore: settlements.length >= 20,
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
    if (current is! SettlementLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final settlements = await _repository.getSettlements(
        page: nextPage,
        partnerId: current.filterPartnerId,
        settlementType: current.filterType,
        dateFrom: current.filterDateFrom,
        dateTo: current.filterDateTo,
      );

      emit(current.copyWith(
        settlements: [...current.settlements, ...settlements],
        hasMore: settlements.length >= 20,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(
    SettlementRefreshRequested event,
    Emitter<SettlementState> emit,
  ) async {
    try {
      final current = state;
      final partnerId =
          current is SettlementLoaded ? current.filterPartnerId : null;
      final type = current is SettlementLoaded ? current.filterType : null;

      final results = await Future.wait([
        _repository.getDailySummary(),
        _repository.getSettlements(
          page: 1,
          partnerId: partnerId,
          settlementType: type,
        ),
        _partnerRepository.getPartners(),
      ]);

      final summary = results[0] as DailySettlementSummaryEntity;
      final settlements = results[1] as List<SettlementEntity>;
      final partners = _extractPartners(results[2]);

      final balances = current is SettlementLoaded
          ? current.partnerBalances
          : <String, PartnerBalanceEntity>{};

      emit(SettlementLoaded(
        summary: summary,
        settlements: settlements,
        partners: partners,
        partnerBalances: balances,
        hasMore: settlements.length >= 20,
        currentPage: 1,
        filterPartnerId: partnerId,
        filterType: type,
      ));
    } on ApiException catch (e) {
      emit(SettlementError(e.message));
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
        orderCount: event.orderCount,
        notes: event.notes,
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

  Future<void> _onFilterChanged(
    SettlementFilterChanged event,
    Emitter<SettlementState> emit,
  ) async {
    final current = state;
    if (current is! SettlementLoaded) return;

    emit(const SettlementLoading());
    try {
      final settlements = await _repository.getSettlements(
        page: 1,
        partnerId: event.partnerId,
        settlementType: event.settlementType,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      final summary = await _repository.getDailySummary();

      emit(current.copyWith(
        summary: summary,
        settlements: settlements,
        hasMore: settlements.length >= 20,
        currentPage: 1,
        filterPartnerId: event.partnerId,
        filterType: event.settlementType,
        filterDateFrom: event.dateFrom,
        filterDateTo: event.dateTo,
      ));
    } on ApiException catch (e) {
      emit(SettlementError(e.message));
    }
  }

  Future<void> _onPartnerBalance(
    PartnerBalanceRequested event,
    Emitter<SettlementState> emit,
  ) async {
    final current = state;
    if (current is! SettlementLoaded) return;

    try {
      final balance =
          await _repository.getPartnerBalance(event.partnerId);

      emit(current.copyWith(
        partnerBalances: {
          ...current.partnerBalances,
          event.partnerId: balance,
        },
      ));
    } on ApiException {
      // Silently fail — balance will show as unavailable
    }
  }

  Future<void> _onCreatePartner(
    PartnerCreateRequested event,
    Emitter<SettlementState> emit,
  ) async {
    try {
      final data = CreatePartnerModel(
        name: event.name,
        partnerType: 0,
        phone: event.phone,
        address: event.address,
        commissionType: 0,
        commissionValue: 0,
        defaultPaymentMethod: 0,
      );
      final result = await _partnerRepository.createPartner(data: data);
      if (result is ApiSuccess<PartnerModel>) {
        emit(const PartnerCreated());
        // Refresh to include the new partner
        add(const SettlementRefreshRequested());
      } else if (result is ApiFailure<PartnerModel>) {
        emit(SettlementError(
          (result as ApiFailure<PartnerModel>).error.arabicMessage,
        ));
      }
    } on ApiException catch (e) {
      emit(SettlementError(e.message));
    }
  }

  /// Extract partners list from the ApiResult returned by PartnerRepository.
  List<PartnerModel> _extractPartners(dynamic result) {
    if (result is ApiSuccess<List<PartnerModel>>) {
      return result.data;
    }
    return [];
  }
}
