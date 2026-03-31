import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/connectivity_service.dart';
import 'queue_operation.dart';

typedef OperationExecutor = Future<void> Function(QueueOperation op);

class OfflineQueueService {
  OfflineQueueService._();
  static final OfflineQueueService instance = OfflineQueueService._();

  static const _boxName = 'offline_queue';

  late Box<String> _box;
  OperationExecutor? _executor;
  StreamSubscription<bool>? _connectivitySub;
  bool _isFlushing = false;

  Future<void> initialize({required OperationExecutor executor}) async {
    _box = await Hive.openBox<String>(_boxName);
    _executor = executor;

    _connectivitySub =
        ConnectivityService.instance.onConnectivityChanged.listen((isOnline) {
      if (isOnline) flush();
    });

    // Flush any pending operations from previous session
    if (ConnectivityService.instance.isOnline) {
      flush();
    }
  }

  Future<void> enqueue(QueueOperation op) async {
    await _box.put(op.id, jsonEncode(op.toJson()));
  }

  Future<QueueOperation> enqueueNew({
    required QueueOperationType type,
    required String orderId,
    required Map<String, dynamic> payload,
  }) async {
    final op = QueueOperation(
      id: const Uuid().v4(),
      type: type,
      orderId: orderId,
      payload: payload,
      enqueuedAt: DateTime.now(),
    );
    await enqueue(op);
    return op;
  }

  List<QueueOperation> get pendingOperations {
    return _box.values
        .map((v) => QueueOperation.fromJson(
              Map<String, dynamic>.from(jsonDecode(v) as Map),
            ))
        .toList()
      ..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
  }

  bool get hasPending => _box.isNotEmpty;

  int get pendingCount => _box.length;

  Future<void> flush() async {
    if (_isFlushing || _executor == null) return;
    if (!ConnectivityService.instance.isOnline) return;

    _isFlushing = true;
    try {
      final ops = pendingOperations;
      for (final op in ops) {
        if (!ConnectivityService.instance.isOnline) break;
        try {
          await _executor!(op);
          await _box.delete(op.id);
        } catch (_) {
          // Leave in queue to retry later
          break;
        }
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> remove(String operationId) async {
    await _box.delete(operationId);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
