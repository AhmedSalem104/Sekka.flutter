import 'package:equatable/equatable.dart';

class DailySettlementSummaryEntity extends Equatable {
  const DailySettlementSummaryEntity({
    required this.date,
    required this.totalCollected,
    required this.totalSettled,
    required this.remainingBalance,
    required this.settlementCount,
    required this.pendingPartners,
  });

  final String date;
  final double totalCollected;
  final double totalSettled;
  final double remainingBalance;
  final int settlementCount;
  final int pendingPartners;

  @override
  List<Object?> get props => [
        date,
        totalCollected,
        totalSettled,
        remainingBalance,
        settlementCount,
        pendingPartners,
      ];
}
