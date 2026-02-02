class AppSettings {
  final int id;
  final bool hasCompletedOnboarding;
  final DateTime? onboardingCompletedAt;
  final double? initialBalance;
  final DateTime? lastClosedMonth;
  final String? geminiApiKey;

  AppSettings({
    required this.id,
    required this.hasCompletedOnboarding,
    this.onboardingCompletedAt,
    this.initialBalance,
    this.lastClosedMonth,
    this.geminiApiKey,
  });
}
