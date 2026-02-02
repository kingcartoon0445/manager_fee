import '../entities/recurring_transaction.dart';
import '../repositories/recurring_transaction_repository.dart';

class GetRecurringTransactionsUseCase {
  final RecurringTransactionRepository repository;

  GetRecurringTransactionsUseCase(this.repository);

  Future<List<RecurringTransaction>> call() {
    return repository.getRecurringTransactions();
  }
}
