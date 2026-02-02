import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/add_transaction_usecase.dart';
import '../../../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../../../domain/usecases/get_transactions_usecase.dart';
import '../../../../domain/usecases/get_categories_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransactionUseCase addTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  TransactionBloc({
    required this.addTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.getDashboardStatsUseCase,
    required this.getCategoriesUseCase,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await getTransactionsUseCase();
      final stats = await getDashboardStatsUseCase(DateTime.now());
      final categories = await getCategoriesUseCase();
      print('--- CATEGORY DATABASE DUMP (${categories.length}) ---');
      for (var c in categories) {
        print(
            'ID: ${c.id}, Name: "${c.name}", Type: ${c.type} (${c.type == 1 ? "Expense" : "Income"}), Icon: "${c.icon}", Color: ${c.colorValue}');
      }
      print('----------------------------------------------------');
      emit(TransactionLoaded(
          transactions: transactions, stats: stats, categories: categories));
    } catch (e) {
      emit(TransactionError("Unable to load transactions: $e"));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    // Keep current state if loaded to show loading overlay or similar,
    // but here we just emit loading then reload.
    // Ideally we should have a separate status for 'adding'.
    emit(TransactionLoading());
    try {
      await addTransactionUseCase(event.transaction);
      // Reload updated data
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError("Failed to add transaction: $e"));
    }
  }
}
