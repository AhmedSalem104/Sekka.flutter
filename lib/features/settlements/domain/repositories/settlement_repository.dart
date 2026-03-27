import 'dart:io';

import '../../../../shared/network/paginated_response.dart';
import '../entities/daily_settlement_summary_entity.dart';
import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Future<PaginatedResponse<SettlementEntity>> getSettlements({
    int pageNumber = 1,
    int pageSize = 20,
    String? dateFrom,
    String? dateTo,
  });

  Future<SettlementEntity> createSettlement({
    required String partnerId,
    required double amount,
    required int settlementType,
    String? notes,
    required bool sendWhatsApp,
  });

  Future<DailySettlementSummaryEntity> getDailySummary({String? date});

  Future<void> uploadReceipt(String settlementId, File file);
}
