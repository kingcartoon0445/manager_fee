import '../../core/category_icons.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/isar_service.dart';
import '../models/category_model.dart';
import 'package:isar/isar.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final IsarService isarService;

  CategoryRepositoryImpl(this.isarService);

  @override
  Future<void> addCategory(Category category) async {
    final isar = await isarService.db;
    final model = CategoryModel()
      ..name = category.name
      ..type = TransactionType.values[category.type]
      ..icon = category.icon
      // Color is dynamic, not stored
      ..parentId = category.parentId;

    await isar.writeTxn(() async {
      await isar.categoryModels.put(model);
    });
  }

  @override
  Future<void> deleteCategory(int id) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.categoryModels.delete(id);
    });
  }

  @override
  Future<List<Category>> getCategories() async {
    final isar = await isarService.db;
    final models = await isar.categoryModels.where().findAll();
    return models
        .map(
          (e) => Category(
            id: e.id,
            name: e.name,
            type: e.type.index,
            icon: e.icon,
            // DYNAMIC COLOR INJECTION
            colorValue: CategoryIcons.getColorByName(e.name).value,
            parentId: e.parentId,
          ),
        )
        .toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(int type) async {
    final isar = await isarService.db;
    // Assuming TransactionType is ordinal: 0, 1.
    final models = await isar.categoryModels
        .filter()
        .typeEqualTo(TransactionType.values[type])
        .findAll();

    return models
        .map(
          (e) => Category(
            id: e.id,
            name: e.name,
            type: e.type.index,
            icon: e.icon,
            // DYNAMIC COLOR INJECTION
            colorValue: CategoryIcons.getColorByName(e.name).value,
            parentId: e.parentId,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    if (category.id == null) return;
    final isar = await isarService.db;
    final existing = await isar.categoryModels.get(category.id!);
    if (existing != null) {
      existing.name = category.name;
      existing.type = TransactionType.values[category.type];
      existing.icon = category.icon;
      // Color is dynamic, not stored
      existing.parentId = category.parentId;

      await isar.writeTxn(() async {
        await isar.categoryModels.put(existing);
      });
    }
  }
}
