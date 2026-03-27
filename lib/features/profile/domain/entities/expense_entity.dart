import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.amount,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String category;
  final double amount;
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, category, amount, notes, createdAt];
}
