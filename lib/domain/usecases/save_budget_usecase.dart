import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class SaveBudgetUseCase {
  final BudgetRepository repository;

  SaveBudgetUseCase(this.repository);

  Future<void> call(Budget budget) {
    return repository.saveBudget(budget);
  }
}
