part of 'settlement_bloc.dart';

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

final class SettlementLoaded extends SettlementState {
  const SettlementLoaded({
    required this.summary,
    required this.settlements,
    required this.partners,
    this.partnerBalances = const {},
    this.isLoadingBalances = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.filterPartnerId,
    this.filterType,
    this.filterDateFrom,
    this.filterDateTo,
  });

  final DailySettlementSummaryEntity summary;
  final List<SettlementEntity> settlements;
  final List<PartnerModel> partners;
  final Map<String, PartnerBalanceEntity> partnerBalances;

  /// True while a batch balance fetch is running for all partners.
  final bool isLoadingBalances;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final String? filterPartnerId;
  final int? filterType;
  final String? filterDateFrom;
  final String? filterDateTo;

  SettlementLoaded copyWith({
    DailySettlementSummaryEntity? summary,
    List<SettlementEntity>? settlements,
    List<PartnerModel>? partners,
    Map<String, PartnerBalanceEntity>? partnerBalances,
    bool? isLoadingBalances,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? filterPartnerId,
    int? filterType,
    String? filterDateFrom,
    String? filterDateTo,
    bool clearFilters = false,
  }) {
    return SettlementLoaded(
      summary: summary ?? this.summary,
      settlements: settlements ?? this.settlements,
      partners: partners ?? this.partners,
      partnerBalances: partnerBalances ?? this.partnerBalances,
      isLoadingBalances: isLoadingBalances ?? this.isLoadingBalances,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterPartnerId:
          clearFilters ? null : (filterPartnerId ?? this.filterPartnerId),
      filterType: clearFilters ? null : (filterType ?? this.filterType),
      filterDateFrom:
          clearFilters ? null : (filterDateFrom ?? this.filterDateFrom),
      filterDateTo:
          clearFilters ? null : (filterDateTo ?? this.filterDateTo),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        settlements,
        partners,
        partnerBalances,
        isLoadingBalances,
        hasMore,
        currentPage,
        isLoadingMore,
        filterPartnerId,
        filterType,
        filterDateFrom,
        filterDateTo,
      ];
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

final class PartnerCreated extends SettlementState {
  const PartnerCreated();
}

final class SettlementError extends SettlementState {
  const SettlementError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
