import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.typeName,
    required this.typeNameAr,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  final String id;
  final int type;
  final String typeName;
  final String typeNameAr;
  final double amount;
  final double balanceAfter;
  final String description;
  final String? referenceId;
  final DateTime createdAt;

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0 && type != 3; // not settlement
  bool get isSettlement => type == 3;

  @override
  List<Object?> get props => [id, type, amount, createdAt];
}
