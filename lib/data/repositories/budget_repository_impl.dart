import 'package:isar/isar.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/isar_service.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final IsarService isarService;

  BudgetRepositoryImpl(this.isarService);

  @override
  Future<List<Budget>> getBudgets() async {
    final isar = await isarService.db;
    final models = await isar.budgetModels.where().findAll();
    return models
        .map((e) => Budget(
              id: e.id,
              name: e.name,
              amount: e.amount,
              categoryId: e.categoryId,
              startDate: e.startDate,
              endDate: e.endDate,
            ))
        .toList();
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final isar = await isarService.db;
    final model = BudgetModel()
      ..name = budget.name
      ..amount = budget.amount
      ..categoryId = budget.categoryId
      ..startDate = budget.startDate
      ..endDate = budget.endDate;

    await isar.writeTxn(() async {
      await isar.budgetModels.put(model);
    });
  }

  @override
  Future<void> deleteBudget(int id) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.budgetModels.delete(id);
    });
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    if (budget.id == null) return;
    final isar = await isarService.db;
    final existing = await isar.budgetModels.get(budget.id!);

    if (existing != null) {
      existing.name = budget.name;
      existing.amount = budget.amount;
      existing.categoryId = budget.categoryId;
      existing.startDate = budget.startDate;
      existing.endDate = budget.endDate;

      await isar.writeTxn(() async {
        await isar.budgetModels.put(existing);
      });
    }
  }
}
