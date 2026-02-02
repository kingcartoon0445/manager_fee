import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final double amount;
  final int type; // 0: Income, 1: Expense
  final int categoryId;
  final DateTime date;
  final String? note;
  final String? memberId;
  final List<String>? tags;

  const Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.memberId,
    this.tags,
    this.budgetId,
  });

  final int? budgetId;

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        categoryId,
        date,
        note,
        note,
        memberId,
        tags,
        budgetId,
      ];
}
