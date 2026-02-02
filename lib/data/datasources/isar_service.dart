import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/monthly_report_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/app_settings_model.dart';
import '../models/quick_shopping_item_model.dart';
import '../models/monthly_surplus_model.dart';
import 'package:flutter/material.dart'; // For Colors/Icons

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          CategoryModelSchema,
          TransactionModelSchema,
          MonthlyReportModelSchema,
          BudgetModelSchema,
          RecurringTransactionModelSchema,
          AppSettingsModelSchema,
          QuickShoppingItemModelSchema,
          MonthlySurplusModelSchema
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Generic CRUD helpers or specific methods can be added here

  Future<void> seedQuickShoppingItemsIfNeeded() async {
    final isar = await db;
    final count = await isar.quickShoppingItemModels.count();
    if (count == 0) {
      final defaultItems = [
        QuickShoppingItemModel()
          ..label = 'Thịt & Cá'
          ..iconCodePoint = Icons.set_meal.codePoint
          ..iconFontFamily = Icons.set_meal.fontFamily
          ..iconFontPackage = Icons.set_meal.fontPackage
          ..colorValue = Colors.red.value
          ..dbCategoryId = 2 // Ăn uống
          ..note = 'Đi chợ: Thịt & Cá',
        QuickShoppingItemModel()
          ..label = 'Rau Củ'
          ..iconCodePoint = Icons.eco.codePoint
          ..iconFontFamily = Icons.eco.fontFamily
          ..iconFontPackage = Icons.eco.fontPackage
          ..colorValue = Colors.green.value
          ..dbCategoryId = 2
          ..note = 'Đi chợ: Rau Củ',
        QuickShoppingItemModel()
          ..label = 'Trái Cây'
          ..iconCodePoint = Icons.apple.codePoint
          ..iconFontFamily = Icons.apple.fontFamily
          ..iconFontPackage = Icons.apple.fontPackage
          ..colorValue = Colors.orange.value
          ..dbCategoryId = 2
          ..note = 'Đi chợ: Trái Cây',
        QuickShoppingItemModel()
          ..label = 'Sữa & Bánh'
          ..iconCodePoint = Icons.bakery_dining.codePoint
          ..iconFontFamily = Icons.bakery_dining.fontFamily
          ..iconFontPackage = Icons.bakery_dining.fontPackage
          ..colorValue = Colors.blue.value
          ..dbCategoryId = 2
          ..note = 'Đi chợ: Sữa & Bánh',
        QuickShoppingItemModel()
          ..label = 'Gia Vị'
          ..iconCodePoint = Icons.soup_kitchen.codePoint
          ..iconFontFamily = Icons.soup_kitchen.fontFamily
          ..iconFontPackage = Icons.soup_kitchen.fontPackage
          ..colorValue = Colors.amber.value
          ..dbCategoryId = 2
          ..note = 'Đi chợ: Gia Vị',
        QuickShoppingItemModel()
          ..label = 'Đồ Dùng'
          ..iconCodePoint = Icons.shopping_bag.codePoint
          ..iconFontFamily = Icons.shopping_bag.fontFamily
          ..iconFontPackage = Icons.shopping_bag.fontPackage
          ..colorValue = Colors.purple.value
          ..dbCategoryId = 6 // Mua sắm
          ..note = 'Đi chợ: Đồ Dùng',
      ];

      await isar.writeTxn(() async {
        await isar.quickShoppingItemModels.putAll(defaultItems);
      });
    }
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.transactionModels.clear();
      await isar.monthlyReportModels.clear();
      await isar.budgetModels.clear();
      await isar.recurringTransactionModels.clear();
      await isar.quickShoppingItemModels.clear();
      await isar.monthlySurplusModels.clear();
      // Keep CategoryModel and AppSettingsModel
    });
  }
}
