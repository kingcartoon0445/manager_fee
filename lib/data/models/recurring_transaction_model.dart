import 'package:isar/isar.dart';
import 'category_model.dart'; // For TransactionType

part 'recurring_transaction_model.g.dart';

@collection
class RecurringTransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;

  @Enumerated(EnumType.ordinal)
  late TransactionType type;

  late int categoryId;

  String? note;

  late int dayOfMonth;

  String? memberId;
}
