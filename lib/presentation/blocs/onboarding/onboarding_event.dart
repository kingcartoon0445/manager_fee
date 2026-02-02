import 'package:equatable/equatable.dart';
import '../../../domain/entities/recurring_transaction.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class CheckOnboardingStatus extends OnboardingEvent {}

class CompleteOnboarding extends OnboardingEvent {
  final double initialBalance;
  final List<RecurringTransaction> recurringTransactions;

  const CompleteOnboarding({
    required this.initialBalance,
    required this.recurringTransactions,
  });

  @override
  List<Object?> get props => [initialBalance, recurringTransactions];
}
