import 'package:isar/isar.dart';
import 'category_model.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;

  @Enumerated(EnumType.ordinal)
  late TransactionType type;

  late int categoryId;

  late DateTime date;

  String? note;

  String? memberId; // e.g., 'Husband', 'Wife'

  List<String>? tags;

  int? budgetId;
}
