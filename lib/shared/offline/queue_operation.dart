enum QueueOperationType {
  // Order actions
  deliver,
  fail,
  cancel,
  update,
  statusChange,
  transfer,
  partial,
  swapAddress,
  waitingStart,
  waitingStop,

  // Settlement actions
  settlementCreate,

  // Profile actions
  profileUpdate,

  // Break actions
  breakStart,
  breakEnd,

  // Chat actions
  chatSend,

  // Notification actions
  notificationRead,
  notificationReadAll,
}

class QueueOperation {
  QueueOperation({
    required this.id,
    required this.type,
    required this.orderId,
    required this.payload,
    required this.enqueuedAt,
  });

  final String id;
  final QueueOperationType type;
  final String orderId;
  final Map<String, dynamic> payload;
  final DateTime enqueuedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'orderId': orderId,
        'payload': payload,
        'enqueuedAt': enqueuedAt.toIso8601String(),
      };

  factory QueueOperation.fromJson(Map<String, dynamic> json) {
    return QueueOperation(
      id: json['id'] as String,
      type: QueueOperationType.values.byName(json['type'] as String),
      orderId: json['orderId'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
    );
  }
}
