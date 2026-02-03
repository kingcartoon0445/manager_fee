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
    final desiredCategories = <CategoryModel>[
      // SPECIAL
      CategoryModel()
        ..name = 'Số dư đầu kỳ'
        ..type = TransactionType.income
        ..icon = '💵',

      // EXPENSE CATEGORIES
      CategoryModel()
        ..name = 'Ăn uống'
        ..type = TransactionType.expense
        ..icon = '🍜',
      CategoryModel()
        ..name = 'Di chuyển'
        ..type = TransactionType.expense
        ..icon = '🚗',
      CategoryModel()
        ..name = 'Giải trí'
        ..type = TransactionType.expense
        ..icon = '🎮',
      CategoryModel()
        ..name = 'Sức khỏe'
        ..type = TransactionType.expense
        ..icon = '🏥',
      CategoryModel()
        ..name = 'Mua sắm'
        ..type = TransactionType.expense
        ..icon = '🛍️',
      CategoryModel()
        ..name = 'Phim ảnh'
        ..type = TransactionType.expense
        ..icon = '🎬',
      CategoryModel()
        ..name = 'Giáo dục'
        ..type = TransactionType.expense
        ..icon = '📚',
      CategoryModel()
        ..name = 'Hóa đơn'
        ..type = TransactionType.expense
        ..icon = '💡',
      CategoryModel()
        ..name = 'Nhà cửa'
        ..type = TransactionType.expense
        ..icon = '🏠',
      CategoryModel()
        ..name = 'Quà tặng'
        ..type = TransactionType.expense
        ..icon = '🎁',
      CategoryModel()
        ..name = 'Du lịch'
        ..type = TransactionType.expense
        ..icon = '✈️',
      CategoryModel()
        ..name = 'Chợ'
        ..type = TransactionType.expense
        ..icon = '🏪',

      // NEW FAMILY CATEGORIES
      CategoryModel()
        ..name = 'Con cái'
        ..type = TransactionType.expense
        ..icon = '👶',
      CategoryModel()
        ..name = 'Hiếu hỉ'
        ..type = TransactionType.expense
        ..icon = '💌',
      CategoryModel()
        ..name = 'Điện nước'
        ..type = TransactionType.expense
        ..icon = '⚡',
      CategoryModel()
        ..name = 'Bảo hiểm'
        ..type = TransactionType.expense
        ..icon = '🛡️',
      CategoryModel()
        ..name = 'Sửa chữa'
        ..type = TransactionType.expense
        ..icon = '🔧',
      CategoryModel()
        ..name = 'Làm đẹp'
        ..type = TransactionType.expense
        ..icon = '💄',
      CategoryModel()
        ..name = 'Thú cưng'
        ..type = TransactionType.expense
        ..icon = '🐶',

      // INCOME CATEGORIES
      CategoryModel()
        ..name = 'Thưởng'
        ..type = TransactionType.income
        ..icon = '🎉',
      CategoryModel()
        ..name = 'Đầu tư'
        ..type = TransactionType.income
        ..icon = '📈',
      CategoryModel()
        ..name = 'Freelance'
        ..type = TransactionType.income
        ..icon = '💼',
      CategoryModel()
        ..name = 'Lương'
        ..type = TransactionType.income
        ..icon = '💰',
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
