import '../../domain/repositories/sync_repository.dart';
import '../datasources/sync_remote_datasource.dart';
import '../models/sync_models.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({required SyncRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final SyncRemoteDataSource _remote;

  @override
  Future<SyncStatusModel> getStatus() => _remote.getStatus();

  @override
  Future<SyncPushResult> push({Map<String, dynamic>? data}) =>
      _remote.push(data: data);

  @override
  Future<SyncPullResult> pull({String? since}) =>
      _remote.pull(since: since);

  @override
  Future<void> resolveConflict(Map<String, dynamic> data) =>
      _remote.resolveConflict(data);
}
