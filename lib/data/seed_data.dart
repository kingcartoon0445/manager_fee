import 'package:peadget/data/datasources/isar_service.dart';
import 'package:peadget/data/models/transaction_model.dart';
import 'package:peadget/data/models/category_model.dart';

/// Seed sample data for 5 months (July - November 2025)
class SeedDataExtended {
  final IsarService isarService;

  SeedDataExtended(this.isarService);

  Future<void> seedSampleData() async {
    final isar = await isarService.db;

    // Check if data already exists
    final existingCount = await isar.transactionModels.count();
    if (existingCount > 0) {
      print('Data already exists. Skipping seed.');
      return;
    }

    // ============================================================================
    // SEED CATEGORIES FIRST
    // ============================================================================
    print('🏷️ Seeding categories...');

    final categories = <CategoryModel>[
      // EXPENSE CATEGORIES (type = 1)
      CategoryModel()
        ..name = 'Ăn uống'
        ..type = TransactionType.expense
        ..icon = '🍜'
        ..parentId = null,

      CategoryModel()
        ..name = 'Di chuyển'
        ..type = TransactionType.expense
        ..icon = '🚗'
        ..parentId = null,

      CategoryModel()
        ..name = 'Giải trí'
        ..type = TransactionType.expense
        ..icon = '🎮'
        ..parentId = null,

      CategoryModel()
        ..name = 'Sức khỏe'
        ..type = TransactionType.expense
        ..icon = '🏥'
        ..parentId = null,

      CategoryModel()
        ..name = 'Mua sắm'
        ..type = TransactionType.expense
        ..icon = '🛍️'
        ..parentId = null,

      CategoryModel()
        ..name = 'Giải trí'
        ..type = TransactionType.expense
        ..icon = '🎬'
        ..parentId = null,

      CategoryModel()
        ..name = 'Giáo dục'
        ..type = TransactionType.expense
        ..icon = '📚'
        ..parentId = null,

      CategoryModel()
        ..name = 'Hóa đơn'
        ..type = TransactionType.expense
        ..icon = '💡'
        ..parentId = null,

      CategoryModel()
        ..name = 'Nhà cửa'
        ..type = TransactionType.expense
        ..icon = '🏠'
        ..parentId = null,

      CategoryModel()
        ..name = 'Quà tặng'
        ..type = TransactionType.expense
        ..icon = '🎁'
        ..parentId = null,

      CategoryModel()
        ..name = 'Du lịch'
        ..type = TransactionType.expense
        ..icon = '✈️'
        ..parentId = null,

      CategoryModel()
        ..name = 'Chợ'
        ..type = TransactionType.expense
        ..icon = '🏪'
        ..parentId = null,

      // INCOME CATEGORIES (type = 0)
      CategoryModel()
        ..name = 'Thưởng'
        ..type = TransactionType.income
        ..icon = '🎉'
        ..parentId = null,

      CategoryModel()
        ..name = 'Đầu tư'
        ..type = TransactionType.income
        ..icon = '📈'
        ..parentId = null,

      CategoryModel()
        ..name = 'Freelance'
        ..type = TransactionType.income
        ..icon = '💼'
        ..parentId = null,

      CategoryModel()
        ..name = 'Lương'
        ..type = TransactionType.income
        ..icon = '💰'
        ..parentId = null,
    ];

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(categories);
    });

    print('✅ Seeded ${categories.length} categories');

    // ============================================================================
    // SEED TRANSACTIONS
    // ============================================================================
    final transactions = <TransactionModel>[];

    // Helper function to generate monthly transactions
    void addMonthlyTransactions(
      int year,
      int month, {
      required double salary,
      double bonus = 0,
      double freelance = 0,
      double investment = 0,
    }) {
      // Monthly salary (day 1)
      transactions.add(
        TransactionModel()
          ..amount = salary
          ..type = TransactionType.income
          ..categoryId = 3
          ..date = DateTime(year, month, 1, 9, 0)
          ..note = 'Lương tháng $month'
          ..tags = ['Chồng'],
      );

      // Bonus if any
      if (bonus > 0) {
        transactions.add(
          TransactionModel()
            ..amount = bonus
            ..type = TransactionType.income
            ..categoryId = 12
            ..date = DateTime(year, month, 1, 10, 0)
            ..note = 'Thưởng tháng $month'
            ..tags = [],
        );
      }

      // Freelance if any
      if (freelance > 0) {
        transactions.add(
          TransactionModel()
            ..amount = freelance
            ..type = TransactionType.income
            ..categoryId = 14
            ..date = DateTime(year, month, 15, 14, 0)
            ..note = 'Thu nhập freelance'
            ..tags = [],
        );
      }

      // Investment if any
      if (investment > 0) {
        transactions.add(
          TransactionModel()
            ..amount = investment
            ..type = TransactionType.income
            ..categoryId = 13
            ..date = DateTime(year, month, 20, 10, 0)
            ..note = 'Lợi nhuận đầu tư'
            ..tags = [],
        );
      }

      // Fixed monthly expenses
      // Rent
      transactions.add(
        TransactionModel()
          ..amount = 2000000
          ..type = TransactionType.expense
          ..categoryId = 9
          ..date = DateTime(year, month, 5, 10, 0)
          ..note = 'Tiền nhà tháng $month'
          ..tags = ['CÓ HẠN MỨC'],
      );

      // Utilities
      transactions.add(
        TransactionModel()
          ..amount = 1500000
          ..type = TransactionType.expense
          ..categoryId = 8
          ..date = DateTime(year, month, 5, 11, 0)
          ..note = 'Tiền điện nước'
          ..tags = ['CÓ HẠN MỨC'],
      );

      // Weekly groceries (4 times per month)
      for (int week = 1; week <= 4; week++) {
        transactions.add(
          TransactionModel()
            ..amount = 400000 + (week * 50000)
            ..type = TransactionType.expense
            ..categoryId = 1
            ..date = DateTime(year, month, week * 7, 12, 0)
            ..note = 'Đi chợ tuần $week'
            ..tags = [],
        );
      }

      // Daily meals (random throughout month)
      for (int day = 2; day <= 28; day += 3) {
        transactions.add(
          TransactionModel()
            ..amount = 150000 + (day * 5000)
            ..type = TransactionType.expense
            ..categoryId = 1
            ..date = DateTime(year, month, day, 12, 30)
            ..note = 'Ăn trưa'
            ..tags = [],
        );
      }

      // Transportation (gas, grab)
      for (int i = 0; i < 3; i++) {
        transactions.add(
          TransactionModel()
            ..amount = 200000
            ..type = TransactionType.expense
            ..categoryId = 2
            ..date = DateTime(year, month, 10 + (i * 7), 18, 0)
            ..note = i == 0 ? 'Xăng xe' : 'Grab đi làm'
            ..tags = [],
        );
      }

      // Shopping (1-2 times per month)
      transactions.add(
        TransactionModel()
          ..amount = 800000 + (month * 100000)
          ..type = TransactionType.expense
          ..categoryId = 5
          ..date = DateTime(year, month, 12, 15, 0)
          ..note = 'Mua sắm'
          ..tags = [],
      );

      // Entertainment
      transactions.add(
        TransactionModel()
          ..amount = 300000 + (month * 50000)
          ..type = TransactionType.expense
          ..categoryId = 6
          ..date = DateTime(year, month, 20, 20, 0)
          ..note = month % 2 == 0 ? 'Xem phim' : 'Đi karaoke'
          ..tags = [],
      );
    }

    // ============================================================================
    // JULY 2025 (Tháng 7)
    // ============================================================================
    addMonthlyTransactions(
      2025,
      7,
      salary: 15000000,
      bonus: 500000,
      freelance: 2000000,
    );

    // Summer vacation
    transactions.addAll([
      TransactionModel()
        ..amount = 3000000
        ..type = TransactionType.expense
        ..categoryId = 11
        ..date = DateTime(2025, 7, 15, 10, 0)
        ..note = 'Vé máy bay Phú Quốc'
        ..tags = [],
      TransactionModel()
        ..amount = 4000000
        ..type = TransactionType.expense
        ..categoryId = 11
        ..date = DateTime(2025, 7, 16, 14, 0)
        ..note = 'Khách sạn resort'
        ..tags = [],
      TransactionModel()
        ..amount = 1500000
        ..type = TransactionType.expense
        ..categoryId = 1
        ..date = DateTime(2025, 7, 17, 19, 0)
        ..note = 'Ăn hải sản Phú Quốc'
        ..tags = [],
    ]);

    // ============================================================================
    // AUGUST 2025 (Tháng 8)
    // ============================================================================
    addMonthlyTransactions(
      2025,
      8,
      salary: 15000000,
      freelance: 2500000,
    );

    // Back to school
    transactions.addAll([
      TransactionModel()
        ..amount = 3000000
        ..type = TransactionType.expense
        ..categoryId = 7
        ..date = DateTime(2025, 8, 10, 10, 0)
        ..note = 'Học phí năm học mới'
        ..tags = [],
      TransactionModel()
        ..amount = 1200000
        ..type = TransactionType.expense
        ..categoryId = 5
        ..date = DateTime(2025, 8, 12, 15, 0)
        ..note = 'Mua đồ dùng học tập'
        ..tags = [],
    ]);

    // ============================================================================
    // SEPTEMBER 2025 (Tháng 9)
    // ============================================================================
    addMonthlyTransactions(
      2025,
      9,
      salary: 15000000,
      bonus: 1000000,
      investment: 2000000,
    );

    // Mid-Autumn Festival
    transactions.addAll([
      TransactionModel()
        ..amount = 800000
        ..type = TransactionType.expense
        ..categoryId = 10
        ..date = DateTime(2025, 9, 10, 16, 0)
        ..note = 'Quà trung thu'
        ..tags = [],
      TransactionModel()
        ..amount = 500000
        ..type = TransactionType.expense
        ..categoryId = 1
        ..date = DateTime(2025, 9, 10, 19, 0)
        ..note = 'Tiệc trung thu'
        ..tags = [],
    ]);

    // Health checkup
    transactions.add(
      TransactionModel()
        ..amount = 2500000
        ..type = TransactionType.expense
        ..categoryId = 4
        ..date = DateTime(2025, 9, 20, 9, 0)
        ..note = 'Khám sức khỏe tổng quát'
        ..tags = [],
    );

    // ============================================================================
    // OCTOBER 2025 (Tháng 10)
    // ============================================================================
    addMonthlyTransactions(
      2025,
      10,
      salary: 15000000,
      freelance: 3000000,
    );

    // Birthday celebration
    transactions.addAll([
      TransactionModel()
        ..amount = 1500000
        ..type = TransactionType.expense
        ..categoryId = 10
        ..date = DateTime(2025, 10, 15, 10, 0)
        ..note = 'Quà sinh nhật'
        ..tags = [],
      TransactionModel()
        ..amount = 2000000
        ..type = TransactionType.expense
        ..categoryId = 1
        ..date = DateTime(2025, 10, 15, 19, 0)
        ..note = 'Tiệc sinh nhật'
        ..tags = [],
    ]);

    // ============================================================================
    // NOVEMBER 2025 (Tháng 11)
    // ============================================================================
    addMonthlyTransactions(
      2025,
      11,
      salary: 15000000,
      bonus: 1500000,
      freelance: 2500000,
    );

    // Black Friday shopping
    transactions.addAll([
      TransactionModel()
        ..amount = 3000000
        ..type = TransactionType.expense
        ..categoryId = 5
        ..date = DateTime(2025, 11, 28, 14, 0)
        ..note = 'Black Friday - Điện tử'
        ..tags = [],
      TransactionModel()
        ..amount = 1500000
        ..type = TransactionType.expense
        ..categoryId = 5
        ..date = DateTime(2025, 11, 28, 16, 0)
        ..note = 'Black Friday - Thời trang'
        ..tags = [],
    ]);

    // ============================================================================
    // DECEMBER 2025 (Tháng 12)
    // Insert all transactions
    await isar.writeTxn(() async {
      await isar.transactionModels.putAll(transactions);
    });

    // Calculate and print summary
    print('✅ Seeded ${transactions.length} transactions for Jul-Nov 2025');

    for (int month = 7; month <= 11; month++) {
      final monthTransactions =
          transactions.where((t) => t.date.month == month);
      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      print('   Tháng $month: ${monthTransactions.length} giao dịch - '
          'Thu: ${income.toStringAsFixed(0)}đ, Chi: ${expense.toStringAsFixed(0)}đ');
    }
  }
}
