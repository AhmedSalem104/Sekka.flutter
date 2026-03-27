import 'dart:io';

import '../../../../shared/network/paginated_response.dart';
import '../../domain/entities/daily_settlement_summary_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/settlement_remote_datasource.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  SettlementRepositoryImpl({
    required SettlementRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final SettlementRemoteDataSource _remote;

  @override
  Future<PaginatedResponse<SettlementEntity>> getSettlements({
    int pageNumber = 1,
    int pageSize = 20,
    String? dateFrom,
    String? dateTo,
  }) =>
      _remote.getSettlements(
        pageNumber: pageNumber,
        pageSize: pageSize,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  Future<SettlementEntity> createSettlement({
    required String partnerId,
    required double amount,
    required int settlementType,
    String? notes,
    required bool sendWhatsApp,
  }) =>
      _remote.createSettlement(
        partnerId: partnerId,
        amount: amount,
        settlementType: settlementType,
        notes: notes,
        sendWhatsApp: sendWhatsApp,
      );

  @override
  Future<DailySettlementSummaryEntity> getDailySummary({String? date}) =>
      _remote.getDailySummary(date: date);

  @override
  Future<void> uploadReceipt(String settlementId, File file) =>
      _remote.uploadReceipt(settlementId, file);
}
