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

    // Check if categories already exist
    // Check if categories already exist
    final existingCount = await isar.categoryModels.count();

    if (existingCount > 0) {
      // Check if "Chợ" category exists (for existing users)
      final marketCategory =
          await isar.categoryModels.filter().nameEqualTo('Chợ').findFirst();

      if (marketCategory == null) {
        print('📋 Adding missing "Chợ" category...');
        final newCategory = CategoryModel()
          ..name = 'Chợ'
          ..type = TransactionType.expense
          ..icon = '🏪'
          ..parentId = null;

        await isar.writeTxn(() async {
          await isar.categoryModels.put(newCategory);
        });
        print('✅ Added "Chợ" category.');
      } else {
        print('📋 Categories exist. Skipping migration.');
      }
      return;
    }

    print('🏷️ Migrating categories...');

    final categories = <CategoryModel>[
      // SPECIAL CATEGORY FOR INITIAL BALANCE
      CategoryModel()
        ..name = 'Số dư đầu kỳ'
        ..type = TransactionType.income
        ..icon = '💵'
        ..parentId = null,

      // EXPENSE CATEGORIES (type = 1)
      CategoryModel()
        ..name = 'Ăn uống'
        ..type = TransactionType.expense
        ..icon = '🍜'
        ..parentId = null,

      CategoryModel()
        ..name = 'Di chuyển'
        ..type = TransactionType.expense
        ..icon = '🚗'
        ..parentId = null,

      CategoryModel()
        ..name = 'Giải trí'
        ..type = TransactionType.expense
        ..icon = '🎮'
        ..parentId = null,

      CategoryModel()
        ..name = 'Sức khỏe'
        ..type = TransactionType.expense
        ..icon = '🏥'
        ..parentId = null,

      CategoryModel()
        ..name = 'Mua sắm'
        ..type = TransactionType.expense
        ..icon = '🛍️'
        ..parentId = null,

      CategoryModel()
        ..name = 'Phim ảnh'
        ..type = TransactionType.expense
        ..icon = '🎬'
        ..parentId = null,

      CategoryModel()
        ..name = 'Giáo dục'
        ..type = TransactionType.expense
        ..icon = '📚'
        ..parentId = null,

      CategoryModel()
        ..name = 'Hóa đơn'
        ..type = TransactionType.expense
        ..icon = '💡'
        ..parentId = null,

      CategoryModel()
        ..name = 'Nhà cửa'
        ..type = TransactionType.expense
        ..icon = '🏠'
        ..parentId = null,

      CategoryModel()
        ..name = 'Quà tặng'
        ..type = TransactionType.expense
        ..icon = '🎁'
        ..parentId = null,

      CategoryModel()
        ..name = 'Du lịch'
        ..type = TransactionType.expense
        ..icon = '✈️'
        ..parentId = null,

      CategoryModel()
        ..name = 'Chợ'
        ..type = TransactionType.expense
        ..icon = '🏪'
        ..parentId = null,

      // INCOME CATEGORIES (type = 0)
      CategoryModel()
        ..name = 'Thưởng'
        ..type = TransactionType.income
        ..icon = '🎉'
        ..parentId = null,

      CategoryModel()
        ..name = 'Đầu tư'
        ..type = TransactionType.income
        ..icon = '📈'
        ..parentId = null,

      CategoryModel()
        ..name = 'Freelance'
        ..type = TransactionType.income
        ..icon = '💼'
        ..parentId = null,

      CategoryModel()
        ..name = 'Lương'
        ..type = TransactionType.income
        ..icon = '💰'
        ..parentId = null,
    ];

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(categories);
    });

    print('✅ Migrated ${categories.length} categories successfully!');
  }
}
