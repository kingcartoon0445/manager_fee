import '../entities/recurring_transaction.dart';
import '../repositories/recurring_transaction_repository.dart';

class SaveRecurringTransactionUseCase {
  final RecurringTransactionRepository repository;

  SaveRecurringTransactionUseCase(this.repository);

  Future<void> call(RecurringTransaction transaction) {
    return repository.saveRecurringTransaction(transaction);
  }
}
