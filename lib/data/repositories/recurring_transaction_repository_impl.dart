import 'package:isar/isar.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../datasources/isar_service.dart';
import '../models/recurring_transaction_model.dart';
import '../models/category_model.dart'; // For TransactionType

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final IsarService isarService;

  RecurringTransactionRepositoryImpl(this.isarService);

  @override
  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final isar = await isarService.db;
    final models = await isar.recurringTransactionModels.where().findAll();
    return models
        .map((e) => RecurringTransaction(
              id: e.id,
              amount: e.amount,
              type: e.type.index,
              categoryId: e.categoryId,
              note: e.note,
              dayOfMonth: e.dayOfMonth,
              memberId: e.memberId,
            ))
        .toList();
  }

  @override
  Future<void> saveRecurringTransaction(
      RecurringTransaction transaction) async {
    final isar = await isarService.db;
    final model = RecurringTransactionModel()
      ..amount = transaction.amount
      ..type = TransactionType.values[transaction.type]
      ..categoryId = transaction.categoryId
      ..note = transaction.note
      ..dayOfMonth = transaction.dayOfMonth
      ..memberId = transaction.memberId;

    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.put(model);
    });
  }

  @override
  Future<void> deleteRecurringTransaction(int id) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.delete(id);
    });
  }

  @override
  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    if (transaction.id == null) return;
    final isar = await isarService.db;
    final existing = await isar.recurringTransactionModels.get(transaction.id!);

    if (existing != null) {
      existing.amount = transaction.amount;
      existing.type = TransactionType.values[transaction.type];
      existing.categoryId = transaction.categoryId;
      existing.note = transaction.note;
      existing.dayOfMonth = transaction.dayOfMonth;
      existing.memberId = transaction.memberId;

      await isar.writeTxn(() async {
        await isar.recurringTransactionModels.put(existing);
      });
    }
  }
}
