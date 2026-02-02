import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
  Future<void> updateTransaction(Transaction transaction);
  Future<int?> predictCategoryId(String note, int type);
}
