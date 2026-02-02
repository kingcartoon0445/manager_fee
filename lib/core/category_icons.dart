import 'package:flutter/material.dart';
import '../domain/entities/category.dart';

/// Category icon and color definitions
/// Centralized category information for consistent display across the app
class CategoryIcons {
  // Private constructor to prevent instantiation
  CategoryIcons._();

  // ============================================================================
  // EXPENSE CATEGORIES (Type 1)
  // ============================================================================

  static const Map<String, dynamic> foodAndDining = {
    'id': 1,
    'name': 'Ăn uống',
    'icon': Icons.restaurant,
    'color': Color(0xFFFF9800), // Orange
    'type': 1, // Expense
  };

  static const Map<String, dynamic> transportation = {
    'id': 2,
    'name': 'Di chuyển',
    'icon': Icons.directions_car,
    'color': Color(0xFF2196F3), // Blue
    'type': 1, // Expense
  };

  static const Map<String, dynamic> shopping = {
    'id': 5,
    'name': 'Mua sắm',
    'icon': Icons.shopping_bag,
    'color': Color(0xFFE91E63), // Pink
    'type': 1, // Expense
  };

  static const Map<String, dynamic> health = {
    'id': 4,
    'name': 'Sức khỏe',
    'icon': Icons.favorite,
    'color': Color(0xFFF44336), // Red
    'type': 1, // Expense
  };

  static const Map<String, dynamic> entertainment = {
    'id': 6,
    'name': 'Giải trí',
    'icon': Icons.movie,
    'color': Color(0xFF9C27B0), // Purple
    'type': 1, // Expense
  };

  static const Map<String, dynamic> education = {
    'id': 7,
    'name': 'Giáo dục',
    'icon': Icons.school,
    'color': Color(0xFF3F51B5), // Indigo
    'type': 1, // Expense
  };

  static const Map<String, dynamic> bills = {
    'id': 8,
    'name': 'Hóa đơn',
    'icon': Icons.receipt_long,
    'color': Color(0xFF607D8B), // Blue Grey
    'type': 1, // Expense
  };

  static const Map<String, dynamic> housing = {
    'id': 9,
    'name': 'Nhà ở',
    'icon': Icons.home,
    'color': Color(0xFF795548), // Brown
    'type': 1, // Expense
  };

  static const Map<String, dynamic> gifts = {
    'id': 10,
    'name': 'Quà tặng',
    'icon': Icons.card_giftcard,
    'color': Color(0xFFFF5722), // Deep Orange
    'type': 1, // Expense
  };

  static const Map<String, dynamic> travel = {
    'id': 11,
    'name': 'Du lịch',
    'icon': Icons.flight,
    'color': Color(0xFF00BCD4), // Cyan
    'type': 1, // Expense
  };

  static const Map<String, dynamic> market = {
    'id': 16,
    'name': 'Chợ',
    // Using store_front or local_grocery_store as similar to market
    'icon': Icons.storefront,
    'color': Color(0xFF4CAF50), // Green (Same as Salary, but requested by user)
    'type': 1, // Expense
  };

  // ============================================================================
  // INCOME CATEGORIES (Type 0)
  // ============================================================================

  static const Map<String, dynamic> salary = {
    'id': 3,
    'name': 'Lương',
    'icon': Icons.attach_money,
    'color': Color(0xFF4CAF50), // Green
    'type': 0, // Income
  };

  static const Map<String, dynamic> bonus = {
    'id': 12,
    'name': 'Thưởng',
    'icon': Icons.stars,
    'color': Color(0xFFFFEB3B), // Yellow
    'type': 0, // Income
  };

  static const Map<String, dynamic> investment = {
    'id': 13,
    'name': 'Đầu tư',
    'icon': Icons.trending_up,
    'color': Color(0xFF8BC34A), // Light Green
    'type': 0, // Income
  };

  static const Map<String, dynamic> freelance = {
    'id': 14,
    'name': 'Freelance',
    'icon': Icons.work,
    'color': Color(0xFF009688), // Teal
    'type': 0, // Income
  };

  static const Map<String, dynamic> other = {
    'id': 15,
    'name': 'Danh mục khác',
    'icon': Icons.category,
    'color': Color(0xFF9E9E9E), // Grey
    'type': 1, // Can be both
  };

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get all expense categories
  static List<Map<String, dynamic>> getExpenseCategories() {
    return [
      foodAndDining,
      transportation,
      shopping,
      health,
      entertainment,
      education,
      bills,
      housing,
      gifts,
      travel,
      market,
      other,
    ];
  }

  /// Get all income categories
  static List<Map<String, dynamic>> getIncomeCategories() {
    return [
      salary,
      bonus,
      investment,
      freelance,
      other,
    ];
  }

  /// Get category info by ID
  static Map<String, dynamic> getCategoryById(int categoryId) {
    final allCategories = [
      ...getExpenseCategories(),
      ...getIncomeCategories(),
    ];

    try {
      return allCategories.firstWhere(
        (cat) => cat['id'] == categoryId,
        orElse: () => other,
      );
    } catch (e) {
      return other;
    }
  }

  /// Get categories by type (0: Income, 1: Expense)
  static List<Map<String, dynamic>> getCategoriesByType(int type) {
    return type == 0 ? getIncomeCategories() : getExpenseCategories();
  }

  /// Get icon by category ID
  static IconData getIconById(int categoryId) {
    final category = getCategoryById(categoryId);
    return category['icon'] as IconData;
  }

  /// Get color by category ID
  static Color getColorById(int categoryId) {
    final category = getCategoryById(categoryId);
    return category['color'] as Color;
  }

  /// Get name by category ID
  static String getNameById(int categoryId) {
    final category = getCategoryById(categoryId);
    return category['name'] as String;
  }

  static Category toDomain(Map<String, dynamic> data) {
    return Category(
      id: data['id'] as int?,
      name: data['name'] as String,
      type: data['type'] as int,
      icon: String.fromCharCode((data['icon'] as IconData).codePoint),
      colorValue: (data['color'] as Color).value,
    );
  }

  /// Get color by category name
  static Color getColorByName(String name) {
    final allCategories = [
      ...getExpenseCategories(),
      ...getIncomeCategories(),
    ];

    try {
      final category = allCategories.firstWhere(
        (cat) => cat['name'] == name,
        orElse: () => other,
      );
      return category['color'] as Color;
    } catch (e) {
      return const Color(0xFF9E9E9E); // Default Grey
    }
  }
}
