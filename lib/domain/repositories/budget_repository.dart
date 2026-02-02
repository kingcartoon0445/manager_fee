import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<void> saveBudget(Budget budget);
  Future<void> deleteBudget(int id);
  Future<void> updateBudget(Budget budget);
}
