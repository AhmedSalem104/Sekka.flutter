import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({required WalletRepository repository})
      : _repository = repository,
        super(const WalletInitial()) {
    on<WalletLoadRequested>(_onLoad);
    on<WalletRefreshRequested>(_onRefresh);
    on<WalletNextPageRequested>(_onNextPage);
    on<WalletFilterChanged>(_onFilterChanged);
  }

  final WalletRepository _repository;

  /// Maps filter index to TransactionType filter for API.
  /// API types: 0=orderEarning, 1=commission, 2=settlement
  int? _filterToType(int filterIndex) => switch (filterIndex) {
        1 => 0, // income = OrderEarning (type 0)
        2 => 1, // expense = Commission (type 1)
        3 => 2, // settlement (type 2)
        _ => null, // all
      };

  Future<void> _onLoad(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final balance = await _repository.getBalance();
      final cashStatus = await _repository.getCashStatus();
      final summary = await _repository.getSummary();
      final transactionsPage =
          await _repository.getTransactions(pageNumber: 1);

      emit(WalletLoaded(
        balance: balance,
        cashStatus: cashStatus,
        summary: summary,
        transactions: transactionsPage.items.cast<TransactionEntity>(),
        hasMore: transactionsPage.hasNextPage,
        currentPage: 1,
      ));
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (_) {
      emit(WalletError(AppStrings.unknownError));
    }
  }

  Future<void> _onRefresh(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    final currentFilter =
        state is WalletLoaded ? (state as WalletLoaded).activeFilter : 0;

    try {
      final balance = await _repository.getBalance();
      final cashStatus = await _repository.getCashStatus();
      final summary = await _repository.getSummary();
      final transactionsPage = await _repository.getTransactions(
        pageNumber: 1,
        type: _filterToType(currentFilter),
      );

      emit(WalletLoaded(
        balance: balance,
        cashStatus: cashStatus,
        summary: summary,
        transactions: transactionsPage.items.cast<TransactionEntity>(),
        hasMore: transactionsPage.hasNextPage,
        currentPage: 1,
        activeFilter: currentFilter,
      ));
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (_) {
      emit(WalletError(AppStrings.unknownError));
    }
  }

  Future<void> _onNextPage(
    WalletNextPageRequested event,
    Emitter<WalletState> emit,
  ) async {
    final current = state;
    if (current is! WalletLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await _repository.getTransactions(
        pageNumber: nextPage,
        type: _filterToType(current.activeFilter),
      );

      emit(current.copyWith(
        transactions: [
          ...current.transactions,
          ...result.items.cast<TransactionEntity>(),
        ],
        hasMore: result.hasNextPage,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onFilterChanged(
    WalletFilterChanged event,
    Emitter<WalletState> emit,
  ) async {
    final current = state;
    if (current is! WalletLoaded) return;

    emit(current.copyWith(
      activeFilter: event.filterIndex,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getTransactions(
        pageNumber: 1,
        type: _filterToType(event.filterIndex),
      );

      emit(current.copyWith(
        transactions: result.items.cast<TransactionEntity>(),
        hasMore: result.hasNextPage,
        currentPage: 1,
        activeFilter: event.filterIndex,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(
        activeFilter: event.filterIndex,
        isLoadingMore: false,
      ));
    }
  }
}
