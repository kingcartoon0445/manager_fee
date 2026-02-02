import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int? id;
  final String name;
  final double amount;
  final int? categoryId; // Optional: Budget for specific category or general
  final DateTime startDate;
  final DateTime endDate;

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    this.categoryId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [id, name, amount, categoryId, startDate, endDate];

  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
