import 'package:isar/isar.dart';

part 'app_settings_model.g.dart';

@collection
class AppSettingsModel {
  Id id = Isar.autoIncrement;

  late bool hasCompletedOnboarding;

  DateTime? onboardingCompletedAt;

  DateTime? lastClosedMonth;

  double? initialBalance;

  String? geminiApiKey;

  String? geminiModelId;
}
