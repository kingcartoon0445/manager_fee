import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peadget/data/datasources/isar_service.dart';
import 'package:peadget/data/repositories/transaction_repository_impl.dart';
import 'package:peadget/data/repositories/category_repository_impl.dart';
import 'package:peadget/data/repositories/budget_repository_impl.dart';
import 'package:peadget/data/repositories/recurring_transaction_repository_impl.dart';
import 'package:peadget/data/repositories/admin_repository_impl.dart';
import 'package:peadget/data/repositories/app_settings_repository_impl.dart';
import 'package:peadget/domain/repositories/transaction_repository.dart';
import 'package:peadget/domain/repositories/category_repository.dart';
import 'package:peadget/domain/repositories/budget_repository.dart';
import 'package:peadget/domain/repositories/recurring_transaction_repository.dart';

import 'package:peadget/domain/repositories/app_settings_repository.dart';
import 'package:peadget/domain/repositories/chat_repository.dart';
import 'package:peadget/data/repositories/chat_repository_impl.dart';
import 'package:peadget/domain/usecases/add_transaction_usecase.dart';
import 'package:peadget/domain/usecases/get_transactions_usecase.dart';
import 'package:peadget/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:peadget/domain/usecases/get_budgets_usecase.dart';
import 'package:peadget/domain/usecases/save_budget_usecase.dart';
import 'package:peadget/domain/usecases/update_budget_usecase.dart';
import 'package:peadget/domain/usecases/delete_budget_usecase.dart';
import 'package:peadget/domain/usecases/get_recurring_transactions_usecase.dart';
import 'package:peadget/domain/usecases/save_recurring_transaction_usecase.dart';
import 'package:peadget/domain/usecases/delete_recurring_transaction_usecase.dart';
import 'package:peadget/domain/usecases/process_recurring_transactions_usecase.dart';
import 'package:peadget/domain/usecases/clear_data_usecase.dart';
import 'package:peadget/domain/usecases/get_categories_usecase.dart';
import 'package:peadget/domain/usecases/get_app_settings_usecase.dart';
import 'package:peadget/domain/usecases/save_app_settings_usecase.dart';
import 'package:peadget/domain/usecases/complete_onboarding_usecase.dart';
import 'package:peadget/domain/usecases/predict_category_usecase.dart';
import 'package:peadget/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:peadget/presentation/blocs/budget/budget_bloc.dart';
import 'package:peadget/presentation/blocs/recurring_transaction/recurring_transaction_bloc.dart';
import 'package:peadget/presentation/blocs/report/report_bloc.dart';
import 'package:peadget/presentation/blocs/theme/theme_cubit.dart';
import 'package:peadget/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:peadget/presentation/blocs/quick_shopping/quick_shopping_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => IsarService());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AppSettingsRepository>(
    () => AppSettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));

  sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => SaveBudgetUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));

  sl.registerLazySingleton(() => GetRecurringTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => SaveRecurringTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecurringTransactionUseCase(sl()));
  sl.registerLazySingleton(
      () => ProcessRecurringTransactionsUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => ClearDataUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => PredictCategoryUseCase(sl()));

  sl.registerLazySingleton(() => GetAppSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SaveAppSettingsUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl(), sl(), sl()));

  // Blocs
  sl.registerFactory(
    () => TransactionBloc(
      addTransactionUseCase: sl(),
      getTransactionsUseCase: sl(),
      getDashboardStatsUseCase: sl(),
      getCategoriesUseCase: sl(),
      chatRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => BudgetBloc(
      getBudgetsUseCase: sl(),
      saveBudgetUseCase: sl(),
      updateBudgetUseCase: sl(),
      deleteBudgetUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RecurringTransactionBloc(
      getRecurringTransactionsUseCase: sl(),
      saveRecurringTransactionUseCase: sl(),
      deleteRecurringTransactionUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReportBloc(
      getTransactionsUseCase: sl(),
      getCategoriesUseCase: sl(),
    ),
  );
  sl.registerFactory(() => ThemeCubit(sl()));
  sl.registerFactory(
    () => OnboardingBloc(
      getAppSettingsUseCase: sl(),
      completeOnboardingUseCase: sl(),
    ),
  );
  sl.registerFactory(() => QuickShoppingCubit(sl()));
}
