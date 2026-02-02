import 'package:isar/isar.dart';

part 'quick_shopping_item_model.g.dart';

@collection
class QuickShoppingItemModel {
  Id id = Isar.autoIncrement;

  late String label;

  late int iconCodePoint;

  String? iconFontFamily;

  String? iconFontPackage;

  late int colorValue;

  late int dbCategoryId;

  late String note;
}
