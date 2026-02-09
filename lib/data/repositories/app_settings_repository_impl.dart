import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../../domain/entities/app_settings.dart';
import '../datasources/isar_service.dart';
import '../models/app_settings_model.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final IsarService isarService;

  AppSettingsRepositoryImpl(this.isarService);

  @override
  Future<AppSettings?> getAppSettings() async {
    final isar = await isarService.db;
    // Get the first settings record (there should only be one)
    final model = await isar.appSettingsModels.get(1);

    if (model == null) return null;

    return AppSettings(
      id: model.id,
      hasCompletedOnboarding: model.hasCompletedOnboarding,
      onboardingCompletedAt: model.onboardingCompletedAt,
      initialBalance: model.initialBalance,
      lastClosedMonth: model.lastClosedMonth,
      geminiApiKey: (model.geminiApiKey != null &&
              model.geminiApiKey!.isNotEmpty)
          ? model.geminiApiKey
          : dotenv.env['GEMINI_API_KEY'] ??
              'AIzaSyBvobDBgkpvDyP47SCg45JTnVR3T8ce5yU', // Use env with hardcoded fallback for safety during dev
      geminiModelId: model.geminiModelId ?? dotenv.env['GEMINI_MODEL_ID'],
    );
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    final isar = await isarService.db;
    final model = AppSettingsModel()
      ..id = settings.id
      ..hasCompletedOnboarding = settings.hasCompletedOnboarding
      ..onboardingCompletedAt = settings.onboardingCompletedAt
      ..initialBalance = settings.initialBalance
      ..lastClosedMonth = settings.lastClosedMonth
      ..geminiApiKey = settings.geminiApiKey
      ..geminiModelId = settings.geminiModelId;

    await isar.writeTxn(() async {
      await isar.appSettingsModels.put(model);
    });
  }
}
