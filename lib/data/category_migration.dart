// import 'package:flutter/material.dart'; // Unused
import 'package:isar/isar.dart'; // Used for isarService.db interactions
// import '../../core/category_icons.dart'; // Unused
import 'datasources/isar_service.dart';
import 'models/category_model.dart';

/// One-time migration to seed categories
class CategoryMigration {
  final IsarService isarService;

  CategoryMigration(this.isarService);

  Future<void> seedCategoriesIfNeeded() async {
    final isar = await isarService.db;

    // Define all desired categories
    // Define all desired categories
    final desiredCategories = <CategoryModel>[
      // --- INCOME (Giữ lại để đảm bảo chức năng) ---
      CategoryModel()
        ..name = 'Lương'
        ..type = TransactionType.income
        ..icon = '💰', // Money Bag
      CategoryModel()
        ..name = 'Thưởng'
        ..type = TransactionType.income
        ..icon = '🎉', // Party Popper
      CategoryModel()
        ..name =
            'Đầu tư' // User requested "Đầu tư", mapping to Income logically or could be Expense depending on context, usually Income for returns or Expense for putting money in. User list had "Đầu tư", let's put it in both or stick to standard. Let's make "Đầu tư" an Expense (outflow) as per user list context (expenses), but usually it's tracked as Transfer or Expense. Let's add it as Expense in the user list section below.
        ..type = TransactionType.income
        ..icon = '📈',
      CategoryModel()
        ..name = 'Khác' // Income Other
        ..type = TransactionType.income
        ..icon = '📦',

      // --- EXPENSE (Theo danh sách User yêu cầu) ---
      CategoryModel()
        ..name = 'Nhà'
        ..type = TransactionType.expense
        ..icon = '🏠', // House
      CategoryModel()
        ..name = 'Điện nước'
        ..type = TransactionType.expense
        ..icon = '⚡', // High Voltage (more generic for power/utility)
      CategoryModel()
        ..name = 'Chợ'
        ..type = TransactionType.expense
        ..icon = '🥦', // Broccoli (Market/Food)
      CategoryModel()
        ..name = 'Xăng xe'
        ..type = TransactionType.expense
        ..icon = '⛽', // Fuel Pump
      CategoryModel()
        ..name = 'Sửa chữa'
        ..type = TransactionType.expense
        ..icon = '🔧', // Wrench
      CategoryModel()
        ..name = 'Giáo dục'
        ..type = TransactionType.expense
        ..icon = '📚', // Books
      CategoryModel()
        ..name = 'Điện thoại, 4G'
        ..type = TransactionType.expense
        ..icon = '📱', // Mobile Phone
      CategoryModel()
        ..name = 'Ăn ngoài, Cafe'
        ..type = TransactionType.expense
        ..icon = '☕', // Hot Beverage
      CategoryModel()
        ..name = 'Mua sắm'
        ..type = TransactionType.expense
        ..icon = '🛍️', // Shopping Bags
      CategoryModel()
        ..name = 'Giải trí'
        ..type = TransactionType.expense
        ..icon = '🎬', // Clapper Board (Movies/Entertainment)
      CategoryModel()
        ..name = 'Sức khỏe'
        ..type = TransactionType.expense
        ..icon = '💊', // Pill
      CategoryModel()
        ..name = 'Bảo hiểm'
        ..type = TransactionType.expense
        ..icon = '🛡️', // Shield
      CategoryModel()
        ..name = 'Đầu tư' // Also add as Expense for "Investment outflow"
        ..type = TransactionType.expense
        ..icon =
            '📉', // Chart Decreasing (Money leaving) -> Or just Chart. Let's use generic Chart
      CategoryModel()
        ..name = 'Quà tặng'
        ..type = TransactionType.expense
        ..icon = '🎁', // Wrapped Gift
      CategoryModel()
        ..name = 'Khác'
        ..type = TransactionType.expense
        ..icon = '📦', // Package
    ];

    final existingCategories = await isar.categoryModels.where().findAll();
    final categoriesToAdd = <CategoryModel>[];

    for (var desired in desiredCategories) {
      // Check if exists by name (case-insensitive for safety)
      final exists = existingCategories.any((e) =>
          e.name.toLowerCase() == desired.name.toLowerCase() &&
          e.type == desired.type);

      if (!exists) {
        categoriesToAdd.add(desired);
      }
    }

    if (categoriesToAdd.isNotEmpty) {
      print(
          '🏷️ Migrating: Adding ${categoriesToAdd.length} new categories...');
      await isar.writeTxn(() async {
        await isar.categoryModels.putAll(categoriesToAdd);
      });
      print('✅ Added: ${categoriesToAdd.map((e) => e.name).join(", ")}');
    } else {
      print('📋 all categories exist. Skipping migration.');
    }
  }
}
