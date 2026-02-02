import 'package:equatable/equatable.dart';

class RecurringTransaction extends Equatable {
  final int? id;
  final double amount;
  final int type; // 0: Income, 1: Expense
  final int categoryId;
  final String? note;
  final int dayOfMonth; // Day to generate transaction (1-31)
  final String? memberId;

  const RecurringTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note,
    required this.dayOfMonth,
    this.memberId,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        categoryId,
        note,
        dayOfMonth,
        memberId,
      ];
}
