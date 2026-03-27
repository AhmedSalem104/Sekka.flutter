import 'package:equatable/equatable.dart';

import '../../domain/entities/cash_status_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_balance_entity.dart';
import '../../domain/entities/wallet_summary_entity.dart';

sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

final class WalletInitial extends WalletState {
  const WalletInitial();
}

final class WalletLoading extends WalletState {
  const WalletLoading();
}

final class WalletLoaded extends WalletState {
  const WalletLoaded({
    required this.balance,
    required this.cashStatus,
    required this.summary,
    required this.transactions,
    this.hasMore = true,
    this.currentPage = 1,
    this.activeFilter = 0,
    this.isLoadingMore = false,
  });

  final WalletBalanceEntity balance;
  final CashStatusEntity cashStatus;
  final WalletSummaryEntity summary;
  final List<TransactionEntity> transactions;
  final bool hasMore;
  final int currentPage;
  final int activeFilter; // 0=all, 1=income, 2=expense, 3=settlement
  final bool isLoadingMore;

  WalletLoaded copyWith({
    WalletBalanceEntity? balance,
    CashStatusEntity? cashStatus,
    WalletSummaryEntity? summary,
    List<TransactionEntity>? transactions,
    bool? hasMore,
    int? currentPage,
    int? activeFilter,
    bool? isLoadingMore,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      cashStatus: cashStatus ?? this.cashStatus,
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        cashStatus,
        summary,
        transactions,
        hasMore,
        currentPage,
        activeFilter,
        isLoadingMore,
      ];
}

final class WalletError extends WalletState {
  const WalletError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
