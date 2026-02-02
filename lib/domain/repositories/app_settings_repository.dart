import '../entities/app_settings.dart';

abstract class AppSettingsRepository {
  Future<AppSettings?> getAppSettings();
  Future<void> saveAppSettings(AppSettings settings);
}
