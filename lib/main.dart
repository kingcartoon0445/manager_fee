import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'presentation/blocs/transaction/transaction_bloc.dart';
import 'presentation/blocs/budget/budget_bloc.dart';
import 'presentation/blocs/report/report_bloc.dart';
import 'presentation/blocs/recurring_transaction/recurring_transaction_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/blocs/onboarding/onboarding_bloc.dart';
import 'presentation/blocs/onboarding/onboarding_event.dart';
import 'presentation/blocs/onboarding/onboarding_state.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'data/datasources/isar_service.dart';
import 'data/seed_data_config.dart';
import 'data/category_migration.dart';
import 'domain/usecases/process_recurring_transactions_usecase.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load Environment variables
  await initializeDateFormatting('vi', null);

  await di.init(); // Initialize DI first to use sl()

  // Migrate categories first (one-time)
  final categoryMigration = CategoryMigration(sl<IsarService>());
  await categoryMigration.seedCategoriesIfNeeded();

  // Seed sample data on first launch
  final seedConfig = SeedDataConfig(sl<IsarService>());
  // await seedConfig.seedIfNeeded();

  // Process recurring transactions
  try {
    final processRecurring = sl<ProcessRecurringTransactionsUseCase>();
    await processRecurring();
    print('✅ Processed recurring transactions');
  } catch (e) {
    print('❌ Error processing recurring transactions: $e');
  }

  // Initialize Notifications
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    notificationService.requestPermissions(); // Ask for permission
    notificationService
        .scheduleMonthlySummary(); // Schedule recursive notification
  } catch (e) {
    print('❌ Error initializing notifications: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<TransactionBloc>()),
        BlocProvider(create: (_) => di.sl<BudgetBloc>()),
        BlocProvider(create: (_) => di.sl<ReportBloc>()),
        BlocProvider(create: (_) => di.sl<RecurringTransactionBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(
          create: (_) => di.sl<OnboardingBloc>()..add(CheckOnboardingStatus()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Money Keeper',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
            ],
            locale: const Locale('vi', 'VN'),
            theme: themeState.themeData.copyWith(
              textTheme: GoogleFonts.interTextTheme(),
            ),
            home: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, onboardingState) {
                if (onboardingState is OnboardingRequired) {
                  return const OnboardingPage();
                } else if (onboardingState is OnboardingCompleted) {
                  return const HomePage();
                }
                // Show loading while checking status
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
