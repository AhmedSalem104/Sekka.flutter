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

class SyncedItemModel {
  const SyncedItemModel({
    required this.tempId,
    required this.realId,
    required this.entityType,
    this.operation = '',
  });

  final String tempId;
  final String realId;
  final String entityType;
  final String operation;

  factory SyncedItemModel.fromJson(Map<String, dynamic> json) {
    return SyncedItemModel(
      tempId: json['tempId'] as String? ?? '',
      realId: json['realId'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      operation: json['operation'] as String? ?? '',
    );
  }
}

class SyncPushResult {
  const SyncPushResult({
    this.syncedCount = 0,
    this.conflictCount = 0,
    this.failedCount = 0,
    this.syncedItems = const [],
    this.conflicts = const [],
    this.syncTimestamp,
  });

  factory SyncPushResult.fromJson(Map<String, dynamic> json) {
    return SyncPushResult(
      syncedCount: json['syncedCount'] as int? ?? 0,
      conflictCount: json['conflictCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      syncedItems: (json['syncedItems'] as List<dynamic>?)
              ?.map((e) =>
                  SyncedItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      conflicts: (json['conflicts'] as List<dynamic>?) ?? [],
      syncTimestamp: json['syncTimestamp'] as String?,
    );
  }

  final int syncedCount;
  final int conflictCount;
  final int failedCount;
  final List<SyncedItemModel> syncedItems;
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
