import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<void> call(Budget budget) {
    return repository.updateBudget(budget);
  }
}
