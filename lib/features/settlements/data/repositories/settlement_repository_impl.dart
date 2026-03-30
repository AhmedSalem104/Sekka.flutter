import 'dart:io';

import '../../domain/entities/daily_settlement_summary_entity.dart';
import '../../domain/entities/partner_balance_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/settlement_remote_datasource.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  SettlementRepositoryImpl({
    required SettlementRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final SettlementRemoteDataSource _remote;

  @override
  Future<List<SettlementEntity>> getSettlements({
    int page = 1,
    int pageSize = 20,
    String? partnerId,
    int? settlementType,
    String? dateFrom,
    String? dateTo,
  }) =>
      _remote.getSettlements(
        page: page,
        pageSize: pageSize,
        partnerId: partnerId,
        settlementType: settlementType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  Future<SettlementEntity> createSettlement({
    required String partnerId,
    required double amount,
    required int settlementType,
    int orderCount = 0,
    String? notes,
  }) =>
      _remote.createSettlement(
        partnerId: partnerId,
        amount: amount,
        settlementType: settlementType,
        orderCount: orderCount,
        notes: notes,
      );

  @override
  Future<DailySettlementSummaryEntity> getDailySummary({String? date}) =>
      _remote.getDailySummary(date: date);

  @override
  Future<PartnerBalanceEntity> getPartnerBalance(String partnerId) =>
      _remote.getPartnerBalance(partnerId);

  @override
  Future<void> uploadReceipt(String settlementId, File file) =>
      _remote.uploadReceipt(settlementId, file);
}
