import 'package:equatable/equatable.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/category.dart';
import 'report_event.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<Transaction> transactions;
  final DateTime date;
  final ReportType viewMode;
  final List<Category> categories; // Added this field
  // Can add pre-computer maps here (e.g. Map<CategoryId, double>)

  const ReportLoaded(this.transactions, this.date,
      {required this.categories,
      this.viewMode = ReportType.daily}); // Modified constructor

  @override
  List<Object> get props =>
      [transactions, date, viewMode, categories]; // Added categories to props
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
  @override
  List<Object> get props => [message];
}
