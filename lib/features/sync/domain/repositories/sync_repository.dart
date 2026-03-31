import '../../data/models/sync_models.dart';

abstract class SyncRepository {
  Future<SyncStatusModel> getStatus();
  Future<SyncPushResult> push({Map<String, dynamic>? data});
  Future<SyncPullResult> pull({String? since});
  Future<void> resolveConflict(Map<String, dynamic> data);
}
