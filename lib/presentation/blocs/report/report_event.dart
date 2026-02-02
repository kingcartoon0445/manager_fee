import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object> get props => [];
}

enum ReportType { daily, monthly }

class LoadReportEvent extends ReportEvent {
  final DateTime date;
  final ReportType viewMode;

  const LoadReportEvent(this.date, {this.viewMode = ReportType.daily});

  @override
  List<Object> get props => [date, viewMode];
}
