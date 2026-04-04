import '../../domain/entities/shift_entity.dart';
import '../../domain/entities/shift_summary_entity.dart';
import '../../domain/repositories/shift_repository.dart';
import '../datasources/shift_remote_datasource.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  ShiftRepositoryImpl({required ShiftRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final ShiftRemoteDataSource _remote;

  @override
  Future<ShiftEntity> startShift({
    required double latitude,
    required double longitude,
  }) =>
      _remote.startShift(latitude: latitude, longitude: longitude);

  @override
  Future<ShiftEntity> endShift() => _remote.endShift();

  @override
  Future<ShiftEntity?> getCurrentShift() => _remote.getCurrentShift();

  @override
  Future<ShiftSummaryEntity> getSummary({String? from, String? to}) =>
      _remote.getSummary(from: from, to: to);
}
