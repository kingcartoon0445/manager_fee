import '../repositories/transaction_repository.dart';

class PredictCategoryUseCase {
  final TransactionRepository repository;

  PredictCategoryUseCase(this.repository);

  Future<int?> call(String note, int type) {
    return repository.predictCategoryId(note, type);
  }
}
