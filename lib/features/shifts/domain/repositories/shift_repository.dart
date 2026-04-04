import '../entities/shift_entity.dart';
import '../entities/shift_summary_entity.dart';

abstract class ShiftRepository {
  Future<ShiftEntity> startShift({
    required double latitude,
    required double longitude,
  });
  Future<ShiftEntity> endShift();
  Future<ShiftEntity?> getCurrentShift();
  Future<ShiftSummaryEntity> getSummary({String? from, String? to});
}
