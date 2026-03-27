import 'package:equatable/equatable.dart';

class DailySettlementSummaryEntity extends Equatable {
  const DailySettlementSummaryEntity({
    required this.date,
    required this.totalSettled,
    required this.settlementCount,
    required this.byType,
    this.topPartner,
  });

  final String date;
  final double totalSettled;
  final int settlementCount;
  final List<SettlementByType> byType;
  final TopPartner? topPartner;

  @override
  List<Object?> get props => [date, totalSettled, settlementCount];
}

class SettlementByType extends Equatable {
  const SettlementByType({
    required this.type,
    required this.typeName,
    required this.amount,
    required this.count,
  });

  final int type;
  final String typeName;
  final double amount;
  final int count;

  @override
  List<Object?> get props => [type, amount, count];
}

class TopPartner extends Equatable {
  const TopPartner({
    required this.partnerId,
    required this.partnerName,
    required this.amount,
  });

  final String partnerId;
  final String partnerName;
  final double amount;

  @override
  List<Object?> get props => [partnerId, amount];
}
