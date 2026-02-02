import 'package:isar/isar.dart';

part 'monthly_report_model.g.dart';

@collection
class MonthlyReportModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String monthYear; // Format: "MM-yyyy", e.g., "10-2023"

  double openingBalance = 0;

  double totalIncome = 0;

  double totalExpense = 0;

  double closingBalance = 0;
}
