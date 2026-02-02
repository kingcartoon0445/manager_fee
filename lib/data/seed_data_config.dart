import 'package:peadget/data/models/budget_model.dart';
import 'package:peadget/data/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'seed_data.dart';
import 'datasources/isar_service.dart';

/// Configuration for sample data seeding
/// This file controls what sample data is generated on first app launch
class SeedDataConfig {
  final IsarService isarService;

  SeedDataConfig(this.isarService);

  /// Main method to seed sample data
  /// Only runs on first app launch (when no data exists)
  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeeded = prefs.getBool('has_seeded_data') ?? false;

    if (hasSeeded) {
      print('📊 Sample data already exists. Skipping seed.');
      return;
    }

    print('🌱 First launch detected. Seeding sample data...');

    // Seed the default data (July - November 2025)
    await _seedDefaultData();

    // Mark as seeded
    await prefs.setBool('has_seeded_data', true);
    print('✅ Sample data seeding completed!');
  }

  /// Default sample data: July - November 2025
  /// Change this method to customize the default data
  Future<void> _seedDefaultData() async {
    final seeder = SeedDataExtended(isarService);
    await seeder.seedSampleData();
  }

  /// Clear all data and reset seed flag
  /// Useful for testing or resetting the app
  /// NOTE: Categories are preserved
  Future<void> resetAndReseed() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear the seed flag
    await prefs.remove('has_seeded_data');

    // Clear only transactions and budgets, preserve categories
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.transactionModels.clear();
      await isar.budgetModels.clear();
      // DO NOT clear categoryModels - preserve categories
    });

    print(
        '🔄 Data cleared (categories preserved). App will reseed on next launch.');
  }
}
