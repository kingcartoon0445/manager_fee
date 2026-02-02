import 'package:shared_preferences/shared_preferences.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/recurring_transaction_repository.dart';

class ProcessRecurringTransactionsUseCase {
  final RecurringTransactionRepository recurringRepository;
  final TransactionRepository transactionRepository;
  final SharedPreferences sharedPreferences;

  ProcessRecurringTransactionsUseCase(
    this.recurringRepository,
    this.transactionRepository,
    this.sharedPreferences,
  );

  static const String kInitialStartDateKey = 'initial_recurring_start_date';

  Future<void> call() async {
    final now = DateTime.now();
    // final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // 0. Determine Initial Start Date (First Run Safeguard)
    DateTime initialStartDate;
    final storedMillis = sharedPreferences.getInt(kInitialStartDateKey);
    if (storedMillis == null) {
      // First run: Set start date to TODAY (Start of day)
      // This ensures we don't backfill "past" transactions from earlier this month
      initialStartDate = DateTime(now.year, now.month, now.day);
      await sharedPreferences.setInt(
          kInitialStartDateKey, initialStartDate.millisecondsSinceEpoch);
      print(
          '🚀 First run detected. Initial recurring start date set to: $initialStartDate');
    } else {
      initialStartDate = DateTime.fromMillisecondsSinceEpoch(storedMillis);
    }

    // 1. Get all recurring transactions configurations
    final recurringItems = await recurringRepository.getRecurringTransactions();
    if (recurringItems.isEmpty) return;

    // 2. Get all transactions for the current month to check for duplicates
    final allTransactions = await transactionRepository.getTransactions();
    final thisMonthTransactions = allTransactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    for (var item in recurringItems) {
      // Calculate the target day for this month
      // If dayOfMonth > days in month, use the last day of month (e.g., 31st in non-31-day months)
      int dayToTrigger = item.dayOfMonth;
      if (dayToTrigger > lastDayOfMonth.day) {
        dayToTrigger = lastDayOfMonth.day;
      }

      final targetDate = DateTime(now.year, now.month, dayToTrigger);

      // Only process if the target date has arrived or passed (today or earlier)
      // We compare just the dates (ignoring time)
      final targetDateOnly =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      final todayOnly = DateTime(now.year, now.month, now.day);

      // Rule 1: Cannot be in future
      if (targetDateOnly.isAfter(todayOnly)) {
        continue;
      }

      // Rule 2: Cannot be before initial start date (First run safeguard)
      // Only strictly BEFORE is skipped. If target == initial (Today on first run), we process.
      if (targetDateOnly.isBefore(initialStartDate)) {
        continue;
      }

      // Check if this recurring transaction has already been generated this month
      // We look for a transaction with same category, type, amount, and roughly the same date tag or note
      final alreadyExists = thisMonthTransactions.any((t) {
        return t.categoryId == item.categoryId &&
            t.type == item.type &&
            (t.amount - item.amount).abs() < 0.01 &&
            t.date.day == dayToTrigger;
        // Note: checking strict day match. If user manually deletes and re-adds on different day, it might dup.
        // But for auto-gen check, this is sufficient.
      });

      if (!alreadyExists) {
        final transaction = Transaction(
          amount: item.amount,
          type: item.type,
          categoryId: item.categoryId,
          date: targetDate, // Set date to the scheduled day
          note: item.note ?? 'Khoản cố định hàng tháng',
          memberId: item.memberId,
          tags: const ['Phí định kỳ'],
        );
        await transactionRepository.addTransaction(transaction);
        print(
            '✅ Auto-generated recurring transaction: ${item.note} for date $targetDate');
      }
    }
  }
}
