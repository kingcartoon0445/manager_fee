import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoriesByType(int type);
  Future<void> addCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<void> updateCategory(Category category);
}
