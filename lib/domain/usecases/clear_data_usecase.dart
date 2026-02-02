abstract class AdminRepository {
  Future<void> clearAllData();
}

class ClearDataUseCase {
  final AdminRepository repository;
  ClearDataUseCase(this.repository);
  Future<void> call() => repository.clearAllData();
}
