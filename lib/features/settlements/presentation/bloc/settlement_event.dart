part of 'settlement_bloc.dart';

sealed class SettlementEvent extends Equatable {
  const SettlementEvent();

  @override
  List<Object?> get props => [];
}

/// Load daily summary + settlements + partners.
final class SettlementsLoadRequested extends SettlementEvent {
  const SettlementsLoadRequested();
}

/// Load next page of settlements.
final class SettlementsNextPage extends SettlementEvent {
  const SettlementsNextPage();
}

/// Refresh all data.
final class SettlementRefreshRequested extends SettlementEvent {
  const SettlementRefreshRequested();
}

/// Create a new settlement.
final class SettlementCreateRequested extends SettlementEvent {
  const SettlementCreateRequested({
    required this.partnerId,
    required this.amount,
    required this.settlementType,
    this.orderCount = 0,
    this.notes,
  });

  final String partnerId;
  final double amount;
  final int settlementType;
  final int orderCount;
  final String? notes;

  @override
  List<Object?> get props => [
        partnerId,
        amount,
        settlementType,
        orderCount,
        notes,
      ];
}

/// Upload receipt for a settlement.
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

/// Apply filters to settlement list.
final class SettlementFilterChanged extends SettlementEvent {
  const SettlementFilterChanged({
    this.partnerId,
    this.settlementType,
    this.dateFrom,
    this.dateTo,
  });

  final String? partnerId;
  final int? settlementType;
  final String? dateFrom;
  final String? dateTo;

  @override
  List<Object?> get props => [partnerId, settlementType, dateFrom, dateTo];
}

/// Create a new partner.
final class PartnerCreateRequested extends SettlementEvent {
  const PartnerCreateRequested({
    required this.name,
    required this.phone,
    this.address,
  });

  final String name;
  final String phone;
  final String? address;

  @override
  List<Object?> get props => [name, phone, address];
}

/// Load a specific partner's balance.
final class PartnerBalanceRequested extends SettlementEvent {
  const PartnerBalanceRequested(this.partnerId);

  final String partnerId;

  @override
  List<Object?> get props => [partnerId];
}

/// Load balances for ALL partners in parallel — the checklist view needs
/// this on mount so it can show real amounts in one paint (no tap-to-load).
final class AllPartnerBalancesRequested extends SettlementEvent {
  const AllPartnerBalancesRequested();
}
