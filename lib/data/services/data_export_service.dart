import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:isar/isar.dart';
import '../datasources/isar_service.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/monthly_surplus_model.dart';
import '../models/app_settings_model.dart';

/// Service to export transaction data to JSON file
class DataExportService {
  final IsarService isarService;

  DataExportService(this.isarService);

  /// Export all transactions to JSON file
  Future<String?> exportData() async {
    try {
      final isar = await isarService.db;

      // Get all data
      final transactions = await isar.transactionModels.where().findAll();
      final categories = await isar.categoryModels.where().findAll();
      final budgets = await isar.budgetModels.where().findAll();
      final recurringTransactions =
          await isar.recurringTransactionModels.where().findAll();
      final monthlySurplus = await isar.monthlySurplusModels.where().findAll();
      final appSettings = await isar.appSettingsModels.where().findFirst();

      if (transactions.isEmpty &&
          categories.isEmpty &&
          budgets.isEmpty &&
          recurringTransactions.isEmpty &&
          monthlySurplus.isEmpty &&
          appSettings == null) {
        return null; // No data to export
      }

      // Convert to JSON
      final exportData = {
        'version': '2.0', // Incremented version
        'exportDate': DateTime.now().toIso8601String(),
        'transactionCount': transactions.length,
        'categoryCount': categories.length,
        'budgetCount': budgets.length,
        'recurringTransactionCount': recurringTransactions.length,
        'transactions': transactions
            .map((t) => {
                  'id': t.id,
                  'amount': t.amount,
                  'type':
                      t.type == TransactionType.income ? 'income' : 'expense',
                  'categoryId': t.categoryId,
                  'date': t.date.toIso8601String(),
                  'note': t.note,
                  'memberId': t.memberId,
                  'tags': t.tags,
                  'budgetId': t.budgetId,
                })
            .toList(),
        'categories': categories
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'type':
                      c.type == TransactionType.income ? 'income' : 'expense',
                  'icon': c.icon,
                  'parentId': c.parentId,
                  // ColorValue removed
                })
            .toList(),
        'budgets': budgets
            .map((b) => {
                  'id': b.id,
                  'name': b.name,
                  'amount': b.amount,
                  'categoryId': b.categoryId,
                  'startDate': b.startDate.toIso8601String(),
                  'endDate': b.endDate.toIso8601String(),
                })
            .toList(),
        'recurringTransactions': recurringTransactions
            .map((t) => {
                  'id': t.id,
                  'amount': t.amount,
                  'type':
                      t.type == TransactionType.income ? 'income' : 'expense',
                  'categoryId': t.categoryId,
                  'note': t.note,
                  'dayOfMonth': t.dayOfMonth,
                  'memberId': t.memberId,
                })
            .toList(),
        'monthlySurplus': monthlySurplus
            .map((s) => {
                  'id': s.id,
                  'monthYear': s.monthYear.toIso8601String(),
                  'income': s.income,
                  'expense': s.expense,
                  'surplus': s.surplus,
                  'action': s.action,
                  'createdAt': s.createdAt.toIso8601String(),
                })
            .toList(),
        'appSettings': appSettings != null
            ? {
                'id': appSettings.id,
                'hasCompletedOnboarding': appSettings.hasCompletedOnboarding,
                'onboardingCompletedAt':
                    appSettings.onboardingCompletedAt?.toIso8601String(),
                'lastClosedMonth':
                    appSettings.lastClosedMonth?.toIso8601String(),
                'initialBalance': appSettings.initialBalance,
              }
            : null,
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName =
          'money_keeper_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      // Write to file
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  /// Share exported file
  Future<bool> shareExportedFile(String filePath) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Money Keeper Backup',
        text: 'Backup dữ liệu Money Keeper',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      print('Share error: $e');
      return false;
    }
  }
}
