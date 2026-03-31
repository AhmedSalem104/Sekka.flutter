class SyncStatusModel {
  const SyncStatusModel({
    this.lastSyncAt,
    this.pendingChanges = 0,
    this.conflictsCount = 0,
    this.isOnline = true,
  });

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      lastSyncAt: json['lastSyncAt'] as String?,
      pendingChanges: json['pendingChanges'] as int? ?? 0,
      conflictsCount: json['conflictsCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? true,
    );
  }

  final String? lastSyncAt;
  final int pendingChanges;
  final int conflictsCount;
  final bool isOnline;
}

class SyncPushResult {
  const SyncPushResult({
    this.syncedCount = 0,
    this.conflictCount = 0,
    this.failedCount = 0,
    this.conflicts = const [],
    this.syncTimestamp,
  });

  factory SyncPushResult.fromJson(Map<String, dynamic> json) {
    return SyncPushResult(
      syncedCount: json['syncedCount'] as int? ?? 0,
      conflictCount: json['conflictCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      conflicts: (json['conflicts'] as List<dynamic>?) ?? [],
      syncTimestamp: json['syncTimestamp'] as String?,
    );
  }

  final int syncedCount;
  final int conflictCount;
  final int failedCount;
  final List<dynamic> conflicts;
  final String? syncTimestamp;
}

class SyncPullResult {
  const SyncPullResult({
    this.changes = const [],
    this.serverTimestamp,
    this.hasMore = false,
  });

  factory SyncPullResult.fromJson(Map<String, dynamic> json) {
    return SyncPullResult(
      changes: (json['changes'] as List<dynamic>?) ?? [],
      serverTimestamp: json['serverTimestamp'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final List<dynamic> changes;
  final String? serverTimestamp;
  final bool hasMore;
}
