import 'package:peadget/data/models/category_model.dart';
import 'package:isar/isar.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/isar_service.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final IsarService isarService;

  TransactionRepositoryImpl(this.isarService);

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final isar = await isarService.db;
    final model = TransactionModel()
      ..amount = transaction.amount
      ..type = TransactionType.values[transaction.type]
      ..categoryId = transaction.categoryId
      ..date = transaction.date
      ..note = transaction.note
      ..memberId = transaction.memberId
      ..tags = transaction.tags
      ..budgetId = transaction.budgetId;

    await isar.writeTxn(() async {
      await isar.transactionModels.put(model);
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.transactionModels.delete(id);
    });
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final isar = await isarService.db;
    final models = await isar.transactionModels.where().findAll();
    return models
        .map(
          (e) => Transaction(
            id: e.id,
            amount: e.amount,
            type: e.type.index,
            categoryId: e.categoryId,
            date: e.date,
            note: e.note,
            memberId: e.memberId,
            tags: e.tags,
            budgetId: e.budgetId,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    if (transaction.id == null) return;
    final isar = await isarService.db;

    // Check if exists
    final existing = await isar.transactionModels.get(transaction.id!);
    if (existing != null) {
      existing.amount = transaction.amount;
      existing.type = TransactionType.values[transaction.type];
      existing.categoryId = transaction.categoryId;
      existing.date = transaction.date;
      existing.note = transaction.note;
      existing.memberId = transaction.memberId;
      existing.tags = transaction.tags;
      existing.budgetId = transaction.budgetId;

      await isar.writeTxn(() async {
        await isar.transactionModels.put(existing);
      });
    }
  }

  @override
  Future<int?> predictCategoryId(String note, int type) async {
    if (note.trim().isEmpty) return null;
    final isar = await isarService.db;

    // Fetch all for safe in-memory filtering (avoid 'where' clause issues if codegen is outdated)
    final allTransactions = await isar.transactionModels.where().findAll();

    try {
      final matches = allTransactions.where((t) {
        if (t.type.index != type) return false;
        if (t.note == null) return false;
        return t.note!.toLowerCase().contains(note.toLowerCase());
      }).toList();

      if (matches.isEmpty) return null;

      // Sort by date descending (newest first)
      matches.sort((a, b) => b.date.compareTo(a.date));

      return matches.first.categoryId;
    } catch (e) {
      return null;
    }
  }
}
