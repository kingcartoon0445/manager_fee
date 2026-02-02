import 'package:equatable/equatable.dart';
import '../../../../domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionEvent extends Equatable {
  const RecurringTransactionEvent();
  @override
  List<Object> get props => [];
}

class LoadRecurringTransactions extends RecurringTransactionEvent {}

class AddRecurringTransactionEvent extends RecurringTransactionEvent {
  final RecurringTransaction transaction;
  const AddRecurringTransactionEvent(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class DeleteRecurringTransactionEvent extends RecurringTransactionEvent {
  final int id;
  const DeleteRecurringTransactionEvent(this.id);
  @override
  List<Object> get props => [id];
}
