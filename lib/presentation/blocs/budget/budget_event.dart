import 'package:equatable/equatable.dart';
import '../../../../domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class AddBudgetEvent extends BudgetEvent {
  final Budget budget;
  const AddBudgetEvent(this.budget);
  @override
  List<Object> get props => [budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  final int id;
  const DeleteBudgetEvent(this.id);
  @override
  List<Object> get props => [id];
}

class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;
  const UpdateBudgetEvent(this.budget);
  @override
  List<Object> get props => [budget];
}
