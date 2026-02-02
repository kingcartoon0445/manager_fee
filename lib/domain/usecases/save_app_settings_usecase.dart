import '../repositories/app_settings_repository.dart';
import '../entities/app_settings.dart';

class SaveAppSettingsUseCase {
  final AppSettingsRepository repository;

  SaveAppSettingsUseCase(this.repository);

  Future<void> call(AppSettings settings) async {
    await repository.saveAppSettings(settings);
  }
}
