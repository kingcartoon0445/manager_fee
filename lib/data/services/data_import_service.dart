import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../datasources/isar_service.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/monthly_surplus_model.dart';
import '../models/app_settings_model.dart';

/// Service to import transaction data from JSON file
class DataImportService {
  final IsarService isarService;

  DataImportService(this.isarService);

  /// Pick and import JSON file
  Future<ImportResult> importData() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(
          success: false,
          message: 'Không có file nào được chọn',
        );
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        return ImportResult(
          success: false,
          message: 'Không thể đọc file',
        );
      }

      // Read file
      final file = File(filePath);
      final jsonString = await file.readAsString();

      // Parse JSON
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate structure
      if (!jsonData.containsKey('transactions') &&
          !jsonData.containsKey('categories')) {
        return ImportResult(
          success: false,
          message: 'File không đúng định dạng',
        );
      }

      int totalImported = 0;
      final isar = await isarService.db;

      // 1. Import Categories
      if (jsonData.containsKey('categories')) {
        final categoriesJson = jsonData['categories'] as List;
        final categories = <CategoryModel>[];
        for (final item in categoriesJson) {
          try {
            final category = CategoryModel()
              ..id = item['id'] // Try to keep ID
              ..name = item['name']
              ..type = item['type'] == 'income'
                  ? TransactionType.income
                  : TransactionType.expense
              ..icon = item['icon']
              ..parentId = item['parentId'];
            // Removed colorValue logic as it's no longer in model
            categories.add(category);
          } catch (e) {
            print('Error parsing category: $e');
          }
        }
        await isar.writeTxn(() async {
          await isar.categoryModels.putAll(categories);
        });
        print('Imported ${categories.length} categories');
      }

      // 2. Import Budgets
      if (jsonData.containsKey('budgets')) {
        final budgetsJson = jsonData['budgets'] as List;
        final budgets = <BudgetModel>[];
        for (final item in budgetsJson) {
          try {
            final budget = BudgetModel()
              ..id = item['id'] // Keep ID
              ..name = item['name']
              ..amount = (item['amount'] as num).toDouble()
              ..categoryId = item['categoryId']
              ..startDate = DateTime.parse(item['startDate'])
              ..endDate = DateTime.parse(item['endDate']);
            budgets.add(budget);
          } catch (e) {
            print('Error parsing budget: $e');
          }
        }
        await isar.writeTxn(() async {
          await isar.budgetModels.putAll(budgets);
        });
        print('Imported ${budgets.length} budgets');
      }

      // 3. Import Recurring Transactions
      if (jsonData.containsKey('recurringTransactions')) {
        final recurringJson = jsonData['recurringTransactions'] as List;
        final recurring = <RecurringTransactionModel>[];
        for (final item in recurringJson) {
          try {
            final rec = RecurringTransactionModel()
              ..id = item['id']
              ..amount = (item['amount'] as num).toDouble()
              ..type = item['type'] == 'income'
                  ? TransactionType.income
                  : TransactionType.expense
              ..categoryId = item['categoryId']
              ..note = item['note']
              ..dayOfMonth = item['dayOfMonth']
              ..memberId = item['memberId'];
            recurring.add(rec);
          } catch (e) {
            print('Error parsing recurring: $e');
          }
        }
        await isar.writeTxn(() async {
          await isar.recurringTransactionModels.putAll(recurring);
        });
      }

      // 4. Import Transactions
      if (jsonData.containsKey('transactions')) {
        final transactionsJson = jsonData['transactions'] as List;
        final transactions = <TransactionModel>[];

        for (final item in transactionsJson) {
          try {
            final transaction = TransactionModel()
              // Try to keep original ID if possible, avoiding conflicts might be tricky
              // If we clear data first, keeping ID is fine.
              // If we append, we might want to let Isar generate new ID?
              // Standard behavior: keeping ID overwrites existing.
              ..amount = (item['amount'] as num).toDouble()
              ..type = item['type'] == 'income'
                  ? TransactionType.income
                  : TransactionType.expense
              ..categoryId = item['categoryId'] as int
              ..date = DateTime.parse(item['date'] as String)
              ..note = item['note'] as String?
              ..memberId = item['memberId'] as String?
              ..tags = (item['tags'] as List?)?.cast<String>()
              ..budgetId = item['budgetId'] as int?;

            // Handle nullable ID import if present in JSON?
            // Usually we don't export ID in V1, but V2 we might.
            // If ID is in JSON, use it to deduplicate/overwrite.
            if (item.containsKey('id')) {
              transaction.id = item['id'];
            }

            transactions.add(transaction);
          } catch (e) {
            print('Error parsing transaction: $e');
            // Skip invalid transactions
          }
        }

        if (transactions.isNotEmpty) {
          await isar.writeTxn(() async {
            await isar.transactionModels.putAll(transactions);
          });
          totalImported = transactions.length;
        }
      }

      // 5. Import Monthly Surplus
      if (jsonData.containsKey('monthlySurplus')) {
        final surplusJson = jsonData['monthlySurplus'] as List;
        final surplusList = <MonthlySurplusModel>[];
        for (final item in surplusJson) {
          try {
            final surplus = MonthlySurplusModel()
              ..id = item['id']
              ..monthYear = DateTime.parse(item['monthYear'])
              ..income = (item['income'] as num).toDouble()
              ..expense = (item['expense'] as num).toDouble()
              ..surplus = (item['surplus'] as num).toDouble()
              ..action = item['action']
              ..createdAt = DateTime.parse(item['createdAt']);

            surplusList.add(surplus);
          } catch (e) {
            print('Error parsing surplus: $e');
          }
        }
        if (surplusList.isNotEmpty) {
          await isar.writeTxn(() async {
            await isar.monthlySurplusModels.putAll(surplusList);
          });
        }
      }

      // 6. Import App Settings
      if (jsonData.containsKey('appSettings') &&
          jsonData['appSettings'] != null) {
        try {
          final item = jsonData['appSettings'];

          // We should probably check if we already have settings and update them
          // or just overwrite. Since this is a restore, overwrite is expected.
          // Isar IDs for settings usually 1? Or auto-increment?
          // If we want to fully restore state, we should restore everything.

          final settings = AppSettingsModel()
            ..id = item['id'] // Keep ID
            ..hasCompletedOnboarding = item['hasCompletedOnboarding']
            ..initialBalance = (item['initialBalance'] as num?)?.toDouble()
            ..onboardingCompletedAt = item['onboardingCompletedAt'] != null
                ? DateTime.parse(item['onboardingCompletedAt'])
                : null
            ..lastClosedMonth = item['lastClosedMonth'] != null
                ? DateTime.parse(item['lastClosedMonth'])
                : null;

          await isar.writeTxn(() async {
            await isar.appSettingsModels.clear(); // Clear existing settings
            await isar.appSettingsModels.put(settings);
          });
        } catch (e) {
          print('Error parsing appSettings: $e');
        }
      }

      return ImportResult(
        success: true,
        message: 'Đã import thành công!',
        count: totalImported,
      );
    } catch (e) {
      print('Import error: $e');
      return ImportResult(
        success: false,
        message: 'Lỗi khi import: ${e.toString()}',
      );
    }
  }

  /// Clear all existing data before import
  Future<bool> clearAllData() async {
    try {
      final isar = await isarService.db;
      await isar.writeTxn(() async {
        await isar.transactionModels.clear();
        // Option 1: Clear everything implies a full restore.
        // Option 2: Only clear transactions?
        // User asked for "Update Import/Export ... suitable for new db".
        // A full backup/restore usually implies replacing everything.
        // However, we must be careful. If we clear Categories, we must ensure we have all categories in the backup.
        // Isar Auto-increment IDs might be an issue if we clear and re-insert.
        // But since we are likely restoring a full snapshot, clearing is safer to avoid duplicates.

        await isar.categoryModels.clear();
        await isar.budgetModels.clear();
        await isar.recurringTransactionModels.clear();
        await isar.monthlySurplusModels.clear();
        // Note: We typically don't clear AppSettings on "Clear Data" unless it's a "Factory Reset".
        // But Import performs "clearAllData" before? No, the code above didn't show Import calling clearAllData implicitly.
        // It seems `importData` appends or updates.
        // If the user manually calls `clearAllData`, they might expect a clean slate.
        // Let's clear Surplus models at least.
        // Not clearing AppSettings here as this function might be used for "Delete all transactions"
        // without resetting Onboarding status.
        // But for consistency with "Export includes everything", restoration should ideally handle conflicts.
        // In the import logic above, I explicitly cleared AppSettings before putting the new one.
      });
      return true;
    } catch (e) {
      print('Clear data error: $e');
      return false;
    }
  }
}

/// Result of import operation
class ImportResult {
  final bool success;
  final String message;
  final int? count;

  ImportResult({
    required this.success,
    required this.message,
    this.count,
  });
}
