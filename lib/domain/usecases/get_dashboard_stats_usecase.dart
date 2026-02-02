import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double balance; // Closing Balance
  final double openingBalance;

  DashboardStats(this.totalIncome, this.totalExpense, this.balance,
      {this.openingBalance = 0});
}

class GetDashboardStatsUseCase {
  final TransactionRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<DashboardStats> call(DateTime month) async {
    final transactions = await repository.getTransactions();

    double openingBalance = 0;
    double periodIncome = 0;
    double periodExpense = 0;

    for (var t in transactions) {
      final isBefore = t.date.isBefore(DateTime(month.year, month.month));
      final isCurrent =
          t.date.year == month.year && t.date.month == month.month;

      if (isBefore) {
        if (t.type == 0)
          openingBalance += t.amount;
        else
          openingBalance -= t.amount;
      }

      if (isCurrent) {
        if (t.type == 0)
          periodIncome += t.amount;
        else
          periodExpense += t.amount;
      }
    }

    // Add Initial Balance from Settings here later (for now 0)

    final closingBalance = openingBalance + periodIncome - periodExpense;

    return DashboardStats(
      periodIncome,
      periodExpense,
      closingBalance,
      openingBalance: openingBalance,
    );
  }
}
