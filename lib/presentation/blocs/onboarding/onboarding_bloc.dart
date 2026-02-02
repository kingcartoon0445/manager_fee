import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import '../../../domain/usecases/get_app_settings_usecase.dart';
import '../../../domain/usecases/complete_onboarding_usecase.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetAppSettingsUseCase getAppSettingsUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingBloc({
    required this.getAppSettingsUseCase,
    required this.completeOnboardingUseCase,
  }) : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final settings = await getAppSettingsUseCase();

      if (settings == null || !settings.hasCompletedOnboarding) {
        emit(OnboardingRequired());
      } else {
        emit(OnboardingCompleted());
      }
    } catch (e) {
      emit(OnboardingError('Lỗi khi kiểm tra trạng thái: $e'));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingInProgress());

    try {
      await completeOnboardingUseCase(
        initialBalance: event.initialBalance,
        recurringTransactions: event.recurringTransactions,
      );

      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Lỗi khi hoàn thành thiết lập: $e'));
    }
  }
}
