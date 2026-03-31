import '../../domain/entities/break_entity.dart';
import '../../domain/entities/break_suggestion_entity.dart';
import '../../domain/repositories/break_repository.dart';
import '../datasources/break_remote_datasource.dart';

class BreakRepositoryImpl implements BreakRepository {
  BreakRepositoryImpl({required BreakRemoteDataSource remoteDataSource})
      : _dataSource = remoteDataSource;

  final BreakRemoteDataSource _dataSource;

  @override
  Future<BreakSuggestionEntity> getSuggestion() =>
      _dataSource.getSuggestion();

  @override
  Future<BreakEntity?> getActiveBreak() => _dataSource.getActiveBreak();

  @override
  Future<BreakEntity> startBreak({
    required int energyBefore,
    required String locationDescription,
  }) =>
      _dataSource.startBreak(
        energyBefore: energyBefore,
        locationDescription: locationDescription,
      );

  @override
  Future<BreakEntity> endBreak({required int energyAfter}) =>
      _dataSource.endBreak(energyAfter: energyAfter);

  @override
  Future<List<BreakEntity>> getHistory({int page = 1, int pageSize = 20}) =>
      _dataSource.getHistory(page: page, pageSize: pageSize);
}
