import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.typeName,
    required super.typeNameAr,
    required super.amount,
    required super.balanceAfter,
    required super.description,
    super.referenceId,
    required super.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'transactionType': type,
        'typeName': typeName,
        'typeNameAr': typeNameAr,
        'amount': amount,
        'balanceAfter': balanceAfter,
        'description': description,
        'referenceId': referenceId,
        'createdAt': createdAt.toIso8601String(),
      };

  static int _parseType(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) {
      return switch (raw.toLowerCase()) {
        'orderpayment' || 'orderearning' => 0,
        'commission' => 1,
        'settlement' => 2,
        _ => 0,
      };
    }
    return 0;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: _parseType(json['transactionType'] ?? json['type']),
      typeName: json['typeName'] as String? ?? '',
      typeNameAr: json['typeNameAr'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      referenceId: json['orderId'] as String? ?? json['settlementId'] as String? ?? json['referenceId'] as String?,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
