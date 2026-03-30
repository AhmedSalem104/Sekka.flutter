import 'dart:io';

import '../entities/daily_settlement_summary_entity.dart';
import '../entities/partner_balance_entity.dart';
import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Future<List<SettlementEntity>> getSettlements({
    int page = 1,
    int pageSize = 20,
    String? partnerId,
    int? settlementType,
    String? dateFrom,
    String? dateTo,
  });

  Future<SettlementEntity> createSettlement({
    required String partnerId,
    required double amount,
    required int settlementType,
    int orderCount = 0,
    String? notes,
  });

  Future<DailySettlementSummaryEntity> getDailySummary({String? date});

  Future<PartnerBalanceEntity> getPartnerBalance(String partnerId);

  Future<void> uploadReceipt(String settlementId, File file);
}
