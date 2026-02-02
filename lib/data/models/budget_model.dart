import 'package:isar/isar.dart';

part 'budget_model.g.dart';

@collection
class BudgetModel {
  Id id = Isar.autoIncrement;

  late String name;

  late double amount;

  int? categoryId;

  late DateTime startDate;

  late DateTime endDate;
}
