import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  Future<List<Budget>> call() {
    return repository.getBudgets();
  }
}
