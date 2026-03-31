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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['transactionType'] as int? ?? json['type'] as int? ?? 0,
      typeName: json['typeName'] as String? ?? '',
      typeNameAr: json['typeNameAr'] as String? ?? json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
