import '../../domain/entities/transaction.dart';
import '../../domain/entities/budget.dart';

class FinancialCalculator {
  /// Calculates total income for a specific month
  static double calculateIncome(
      List<Transaction> transactions, DateTime month) {
    return transactions
        .where((t) =>
            t.date.year == month.year &&
            t.date.month == month.month &&
            t.type == 0) // 0 is Income
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Calculates total expense for a specific month
  static double calculateExpense(
      List<Transaction> transactions, DateTime month) {
    return transactions
        .where((t) =>
            t.date.year == month.year &&
            t.date.month == month.month &&
            t.type == 1) // 1 is Expense
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Calculates opening balance at the start of the specified month
  static double calculateOpeningBalance(List<Transaction> allTransactions,
      DateTime month, double initialBalance) {
    final startOfMonth = DateTime(month.year, month.month);

    double preIncome = allTransactions
        .where((t) => t.date.isBefore(startOfMonth) && t.type == 0)
        .fold(0, (sum, t) => sum + t.amount);

    double preExpense = allTransactions
        .where((t) => t.date.isBefore(startOfMonth) && t.type == 1)
        .fold(0, (sum, t) => sum + t.amount);

    return initialBalance + preIncome - preExpense;
  }

  /// Calculates closing balance (Total Assets) at the end of the specified month
  static double calculateClosingBalance(List<Transaction> allTransactions,
      DateTime month, double initialBalance) {
    double opening =
        calculateOpeningBalance(allTransactions, month, initialBalance);
    double income = calculateIncome(allTransactions, month);
    double expense = calculateExpense(allTransactions, month);

    return opening + income - expense;
  }

  /// Calculates Net Available Money (Total Assets - Remaining Budget Limits)
  static double calculateNetAvailable(double totalAssets, List<Budget> budgets,
      List<Transaction> allTransactions) {
    double totalBudgetRemaining = 0;

    for (var b in budgets) {
      // Calculate spent amount for this budget
      // Note: Assuming strict matching by budgetId as implemented in Dashboard
      double spent = allTransactions
          .where((t) => t.type == 1 && t.budgetId == b.id)
          .fold(0.0, (sum, t) => sum + t.amount);

      double remaining = b.amount - spent;
      if (remaining > 0) {
        totalBudgetRemaining += remaining;
      }
    }

    return totalAssets - totalBudgetRemaining;
  }
}
