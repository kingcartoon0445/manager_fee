import '../repositories/app_settings_repository.dart';
import '../entities/app_settings.dart';

class GetAppSettingsUseCase {
  final AppSettingsRepository repository;

  GetAppSettingsUseCase(this.repository);

  Future<AppSettings?> call() async {
    return await repository.getAppSettings();
  }
}
