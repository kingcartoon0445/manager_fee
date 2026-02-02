import '../repositories/app_settings_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/recurring_transaction_repository.dart';
import '../entities/app_settings.dart';
import '../entities/transaction.dart';
import '../entities/recurring_transaction.dart';

class CompleteOnboardingUseCase {
  final AppSettingsRepository appSettingsRepository;
  final TransactionRepository transactionRepository;
  final RecurringTransactionRepository recurringTransactionRepository;

  CompleteOnboardingUseCase(
    this.appSettingsRepository,
    this.transactionRepository,
    this.recurringTransactionRepository,
  );

  Future<void> call({
    required double initialBalance,
    required List<RecurringTransaction> recurringTransactions,
  }) async {
    // 1. Save initial balance as a transaction (if not zero)
    if (initialBalance != 0) {
      final initialBalanceTransaction = Transaction(
        amount: initialBalance.abs(),
        type: initialBalance >= 0 ? 0 : 1, // 0: Income, 1: Expense
        categoryId:
            1, // Special "Initial Balance" category (created in migration)
        date: DateTime.now(),
        note: 'Số dư đầu kỳ',
      );

      await transactionRepository.addTransaction(initialBalanceTransaction);
    }

    // 2. Save all recurring transactions
    for (final recurring in recurringTransactions) {
      await recurringTransactionRepository.saveRecurringTransaction(recurring);
    }

    // 3. Mark onboarding as completed
    final settings = AppSettings(
      id: 1,
      hasCompletedOnboarding: true,
      onboardingCompletedAt: DateTime.now(),
      initialBalance: initialBalance,
    );
    await appSettingsRepository.saveAppSettings(settings);
  }
}
