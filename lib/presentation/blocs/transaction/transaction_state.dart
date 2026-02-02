import 'package:equatable/equatable.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/category.dart';
import '../../../../domain/usecases/get_dashboard_stats_usecase.dart'; // For DashboardStats

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final DashboardStats stats;
  final List<Category> categories;

  const TransactionLoaded({
    required this.transactions,
    required this.stats,
    this.categories = const [],
  });

  @override
  List<Object?> get props => [transactions, stats, categories];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
