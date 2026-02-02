import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_budgets_usecase.dart';
import '../../../../domain/usecases/save_budget_usecase.dart';
import '../../../../domain/usecases/update_budget_usecase.dart';
import '../../../../domain/usecases/delete_budget_usecase.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetsUseCase getBudgetsUseCase;
  final SaveBudgetUseCase saveBudgetUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;

  BudgetBloc({
    required this.getBudgetsUseCase,
    required this.saveBudgetUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
  }) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudgetEvent>(_onAddBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(
      LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final budgets = await getBudgetsUseCase();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError("Failed to load budgets: $e"));
    }
  }

  Future<void> _onAddBudget(
      AddBudgetEvent event, Emitter<BudgetState> emit) async {
    // Optimistic or strict? Strict for now.
    emit(BudgetLoading());
    try {
      await saveBudgetUseCase(event.budget);
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError("Failed to add budget: $e"));
    }
  }

  Future<void> _onDeleteBudget(
      DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await deleteBudgetUseCase(event.id);
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError("Failed to delete budget: $e"));
    }
  }

  Future<void> _onUpdateBudget(
      UpdateBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await updateBudgetUseCase(event.budget);
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError("Failed to update budget: $e"));
    }
  }
}
