import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_recurring_transactions_usecase.dart';
import '../../../../domain/usecases/save_recurring_transaction_usecase.dart';
import '../../../../domain/usecases/delete_recurring_transaction_usecase.dart';
import 'recurring_transaction_event.dart';
import 'recurring_transaction_state.dart';

class RecurringTransactionBloc
    extends Bloc<RecurringTransactionEvent, RecurringTransactionState> {
  final GetRecurringTransactionsUseCase getRecurringTransactionsUseCase;
  final SaveRecurringTransactionUseCase saveRecurringTransactionUseCase;
  final DeleteRecurringTransactionUseCase deleteRecurringTransactionUseCase;

  RecurringTransactionBloc({
    required this.getRecurringTransactionsUseCase,
    required this.saveRecurringTransactionUseCase,
    required this.deleteRecurringTransactionUseCase,
  }) : super(RecurringTransactionInitial()) {
    on<LoadRecurringTransactions>(_onLoad);
    on<AddRecurringTransactionEvent>(_onAdd);
    on<DeleteRecurringTransactionEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadRecurringTransactions event,
      Emitter<RecurringTransactionState> emit) async {
    emit(RecurringTransactionLoading());
    try {
      final items = await getRecurringTransactionsUseCase();
      emit(RecurringTransactionLoaded(items));
    } catch (e) {
      emit(RecurringTransactionError(
          "Failed to load recurring transactions: $e"));
    }
  }

  Future<void> _onAdd(AddRecurringTransactionEvent event,
      Emitter<RecurringTransactionState> emit) async {
    emit(RecurringTransactionLoading());
    try {
      await saveRecurringTransactionUseCase(event.transaction);
      add(LoadRecurringTransactions());
    } catch (e) {
      emit(
          RecurringTransactionError("Failed to add recurring transaction: $e"));
    }
  }

  Future<void> _onDelete(DeleteRecurringTransactionEvent event,
      Emitter<RecurringTransactionState> emit) async {
    emit(RecurringTransactionLoading());
    try {
      await deleteRecurringTransactionUseCase(event.id);
      add(LoadRecurringTransactions());
    } catch (e) {
      emit(RecurringTransactionError(
          "Failed to delete recurring transaction: $e"));
    }
  }
}
