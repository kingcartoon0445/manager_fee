import '../entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getRecurringTransactions();
  Future<void> saveRecurringTransaction(RecurringTransaction transaction);
  Future<void> deleteRecurringTransaction(int id);
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);
}
