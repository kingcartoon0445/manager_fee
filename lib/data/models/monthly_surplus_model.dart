import 'package:isar/isar.dart';

part 'monthly_surplus_model.g.dart';

@collection
class MonthlySurplusModel {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime monthYear; // First day of the month

  double income = 0;
  double expense = 0;
  double surplus = 0;

  // 0: Pending, 1: Saved (Expense created), 2: Rollover (Budget increased)
  int action = 0;

  DateTime createdAt = DateTime.now();
}
