import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String name;

  @Enumerated(EnumType.ordinal)
  late TransactionType type; // 0: Income, 1: Expense

  String? icon;
  // String? icon;
  // int? colorValue; // Removed: Color is now dynamic based on name

  int? parentId; // For sub-categories
}

enum TransactionType { income, expense }
