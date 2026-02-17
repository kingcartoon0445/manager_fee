import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/add_transaction_usecase.dart';
import '../../../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../../../domain/usecases/get_transactions_usecase.dart';
import '../../../../domain/usecases/get_categories_usecase.dart';
import '../../../../domain/repositories/chat_repository.dart'; // Import ChatRepository
import '../../../../core/utils/currency_formatter.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransactionUseCase addTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final ChatRepository chatRepository; // Add repository

  TransactionBloc({
    required this.addTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.getDashboardStatsUseCase,
    required this.getCategoriesUseCase,
    required this.chatRepository, // Add to constructor
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
    emit(TransactionLoading());
    try {
      await addTransactionUseCase(event.transaction);

      // Sync to Chat
      final amountStr = CurrencyFormatter.format(event.transaction.amount);
      final noteStr = event.transaction.note?.isNotEmpty == true
          ? ' - ${event.transaction.note}'
          : '';
      await chatRepository.addMessage(
          text: 'Đã thêm giao dịch: $amountStr$noteStr',
          isUser: false,
          isSystem: true);

      // Reload updated data
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError("Failed to add transaction: $e"));
    }
  }
}
