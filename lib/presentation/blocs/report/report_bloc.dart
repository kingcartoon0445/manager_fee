import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_transactions_usecase.dart';
import '../../../../domain/usecases/get_categories_usecase.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ReportBloc(
      {required this.getTransactionsUseCase,
      required this.getCategoriesUseCase})
      : super(ReportInitial()) {
    on<LoadReportEvent>(_onLoadReport);
  }

  Future<void> _onLoadReport(
      LoadReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final all = await getTransactionsUseCase();
      final categories = await getCategoriesUseCase();
      final filtered = all.where((t) {
        if (event.viewMode == ReportType.daily) {
          // Filter by specific DAY
          return t.date.year == event.date.year &&
              t.date.month == event.date.month &&
              t.date.day == event.date.day;
        } else {
          // Filter by specific MONTH
          return t.date.year == event.date.year &&
              t.date.month == event.date.month;
        }
      }).toList();

      emit(ReportLoaded(filtered, event.date,
          viewMode: event.viewMode, categories: categories));
    } catch (e) {
      emit(ReportError("Failed to load report: $e"));
    }
  }
}
