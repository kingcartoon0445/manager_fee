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
      geminiApiKey: model.geminiApiKey,
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
      ..geminiApiKey = settings.geminiApiKey;

    await isar.writeTxn(() async {
      await isar.appSettingsModels.put(model);
    });
  }
}
