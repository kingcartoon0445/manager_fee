import 'package:equatable/equatable.dart';
import '../../../../domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionState extends Equatable {
  const RecurringTransactionState();
  @override
  List<Object> get props => [];
}

class RecurringTransactionInitial extends RecurringTransactionState {}

class RecurringTransactionLoading extends RecurringTransactionState {}

class RecurringTransactionLoaded extends RecurringTransactionState {
  final List<RecurringTransaction> transactions;
  const RecurringTransactionLoaded(this.transactions);
  @override
  List<Object> get props => [transactions];
}

class RecurringTransactionError extends RecurringTransactionState {
  final String message;
  const RecurringTransactionError(this.message);
  @override
  List<Object> get props => [message];
}
