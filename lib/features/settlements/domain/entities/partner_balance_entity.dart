import 'package:equatable/equatable.dart';

class PartnerBalanceEntity extends Equatable {
  const PartnerBalanceEntity({
    required this.partnerId,
    required this.partnerName,
    required this.totalCollected,
    required this.totalSettled,
    required this.pendingBalance,
    required this.pendingOrderCount,
  });

  final String partnerId;
  final String partnerName;
  final double totalCollected;
  final double totalSettled;
  final double pendingBalance;
  final int pendingOrderCount;

  @override
  List<Object?> get props => [
        partnerId,
        totalCollected,
        totalSettled,
        pendingBalance,
      ];
}
