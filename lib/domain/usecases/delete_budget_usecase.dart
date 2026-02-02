import '../repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteBudget(id);
  }
}
