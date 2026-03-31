import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/connectivity_service.dart';

// ── Data classes ─────────────────────────────────────────────────────────────

class SyncedItem {
  const SyncedItem({
    required this.tempId,
    required this.realId,
    required this.entityType,
  });

  final String tempId;
  final String realId;
  final String entityType;
}

class SyncChange {
  const SyncChange({
    required this.tempId,
    required this.entityType,
    required this.operationType,
    required this.payload,
    required this.enqueuedAt,
  });

  final String tempId;
  final String entityType;
  final int operationType; // 0 = create, 1 = update, 2 = delete
  final Map<String, dynamic> payload;
  final DateTime enqueuedAt;

  Map<String, dynamic> toJson() => {
        'tempId': tempId,
        'entityType': entityType,
        'operationType': operationType,
        'payloadJson': jsonEncode(payload),
        'enqueuedAt': enqueuedAt.toIso8601String(),
      };

  factory SyncChange.fromJson(Map<String, dynamic> json) {
    return SyncChange(
      tempId: json['tempId'] as String,
      entityType: json['entityType'] as String,
      operationType: json['operationType'] as int,
      payload: Map<String, dynamic>.from(
        jsonDecode(json['payloadJson'] as String) as Map,
      ),
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
    );
  }
}

// ── Executor type ─────────────────────────────────────────────────────────────

typedef SyncPushExecutor = Future<List<SyncedItem>> Function(
  List<SyncChange> changes,
);

// ── Service ───────────────────────────────────────────────────────────────────

class SyncQueueService {
  SyncQueueService._();
  static final SyncQueueService instance = SyncQueueService._();

  static const _boxName = 'sync_queue';

  late Box<String> _box;
  SyncPushExecutor? _executor;
  final _syncedController = StreamController<List<SyncedItem>>.broadcast();
  StreamSubscription<bool>? _connectivitySub;
  bool _isFlushing = false;

  /// Emits a list of synced items each time a flush completes successfully.
  Stream<List<SyncedItem>> get syncedItems => _syncedController.stream;

  bool get hasPending => _box.isNotEmpty;
  int get pendingCount => _box.length;

  Future<void> initialize({required SyncPushExecutor executor}) async {
    _box = await Hive.openBox<String>(_boxName);
    _executor = executor;

    _connectivitySub =
        ConnectivityService.instance.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _box.isNotEmpty) flush();
    });

    // Flush anything left over from a previous session
    if (ConnectivityService.instance.isOnline && _box.isNotEmpty) {
      flush();
    }
  }

  /// Enqueues a "create" operation and returns the generated tempId.
  Future<String> enqueueCreate({
    required String entityType,
    required Map<String, dynamic> payload,
  }) async {
    final tempId = 'temp-${const Uuid().v4()}';
    final change = SyncChange(
      tempId: tempId,
      entityType: entityType,
      operationType: 0,
      payload: payload,
      enqueuedAt: DateTime.now(),
    );
    await _box.put(tempId, jsonEncode(change.toJson()));
    return tempId;
  }

  /// Flush all pending changes via /sync/push.
  Future<void> flush() async {
    if (_isFlushing || _executor == null || _box.isEmpty) return;
    if (!ConnectivityService.instance.isOnline) return;

    _isFlushing = true;
    try {
      final changes = _box.values
          .map((v) => SyncChange.fromJson(
                Map<String, dynamic>.from(jsonDecode(v) as Map),
              ))
          .toList()
        ..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));

      final synced = await _executor!(changes);

      for (final item in synced) {
        await _box.delete(item.tempId);
      }

      if (synced.isNotEmpty) {
        _syncedController.add(synced);
      }
    } catch (_) {
      // Leave in queue — will retry on next connectivity change
    } finally {
      _isFlushing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncedController.close();
  }
}
