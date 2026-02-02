import 'package:flutter/material.dart';

/// App color palette
/// Centralized color definitions for consistent theming across the app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================

  /// Primary blue color - used for main actions and highlights
  static const Color primaryBlue = Color(0xFF2962FF);

  /// Deep purple - used for secondary highlights
  static const Color deepPurple = Color(0xFF651FFF);

  /// Light blue - used for backgrounds and accents
  static const Color lightBlue = Color(0xFF2979FF);

  // ============================================================================
  // ACCENT COLORS
  // ============================================================================

  /// Success green - used for positive values and income
  static const Color successGreen = Color(0xFF00E676);

  /// Dark green - used for success states
  static const Color darkGreen = Color(0xFF00C853);

  /// Medium green - used for gradients
  static const Color mediumGreen = Color(0xFF2E7D32);

  /// Error red - used for negative values and expenses
  static const Color errorRed = Color(0xFFFF5252);

  /// Dark red - used for warnings
  static const Color darkRed = Color(0xFFC62828);

  /// Warning orange - used for alerts and budgets
  static const Color warningOrange = Colors.orange;

  /// Deep orange - used for budget highlights
  static const Color deepOrange = Colors.deepOrange;

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Main background color - light grey/white
  static const Color background = Color(0xFFF8F9FD);

  /// Card background - pure white
  static const Color cardBackground = Colors.white;

  /// Light green background - for success states
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  /// Light red background - for error states
  static const Color lightRedBg = Color(0xFFFFEBEE);

  /// Light blue background - for info states
  static const Color lightBlueBg = Color(0xFFE3F2FD);

  /// Light orange background - for warning states
  static const Color lightOrangeBg = Color(0xFFFFF3E0);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Primary text color - dark grey/black
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text color - medium grey
  static const Color textSecondary = Color(0xFF263238);

  /// Tertiary text color - light grey
  static const Color textTertiary = Colors.grey;

  /// Disabled text color
  static Color textDisabled = Colors.grey[400]!;

  /// Hint text color
  static Color textHint = Colors.grey[500]!;

  // ============================================================================
  // BORDER COLORS
  // ============================================================================

  /// Light border color
  static Color borderLight = Colors.grey[200]!;

  /// Medium border color
  static Color borderMedium = Colors.grey[300]!;

  /// Dark border color
  static Color borderDark = Colors.grey[400]!;

  // ============================================================================
  // BUTTON COLORS
  // ============================================================================

  /// Button enabled - primary action
  static const Color buttonEnabled = Color(0xFF2962FF);

  /// Button enabled - success action
  static const Color buttonEnabledSuccess = Color(0xFF00C853);

  /// Button enabled - danger action
  static const Color buttonEnabledDanger = Color(0xFFFF5252);

  /// Button disabled - no value or inactive
  static Color buttonDisabled = Colors.grey[300]!;

  /// Button disabled light - very subtle
  static const Color buttonDisabledLight = Color(0xFFCFD8DC);

  /// Button text enabled
  static const Color buttonTextEnabled = Colors.white;

  /// Button text disabled
  static Color buttonTextDisabled = Colors.grey[400]!;

  // ============================================================================
  // CATEGORY COLORS
  // ============================================================================

  /// Food & Dining
  static const Color categoryFood = Colors.orange;

  /// Transportation
  static const Color categoryTransport = Colors.blue;

  /// Shopping
  static const Color categoryShopping = Colors.pink;

  /// Health
  static const Color categoryHealth = Colors.red;

  /// Education
  static const Color categoryEducation = Colors.indigo;

  /// Bills & Utilities
  static const Color categoryBills = Colors.yellow;

  // ============================================================================
  // GRADIENT COLORS
  // ============================================================================

  /// Green gradient for quick shopping banner
  static const List<Color> greenGradient = [
    Color(0xFF00C853),
    Color(0xFF00E676),
  ];

  /// Blue gradient (if needed)
  static const List<Color> blueGradient = [
    Color(0xFF2962FF),
    Color(0xFF2979FF),
  ];

  // ============================================================================
  // SHADOW COLORS
  // ============================================================================

  /// Light shadow color
  static Color shadowLight = Colors.black.withOpacity(0.02);

  /// Medium shadow color
  static Color shadowMedium = Colors.black.withOpacity(0.03);

  /// Dark shadow color
  static Color shadowDark = Colors.black.withOpacity(0.05);

  /// Card shadow color
  static Color cardShadow = const Color(0xFFE0E0E0).withOpacity(0.5);

  // ============================================================================
  // UTILITY COLORS
  // ============================================================================

  /// Transparent
  static const Color transparent = Colors.transparent;

  /// White
  static const Color white = Colors.white;

  /// Black
  static const Color black = Colors.black;

  /// Grey scale
  static Color grey50 = Colors.grey[50]!;
  static Color grey100 = Colors.grey[100]!;
  static Color grey200 = Colors.grey[200]!;
  static Color grey300 = Colors.grey[300]!;
  static Color grey400 = Colors.grey[400]!;
  static Color grey500 = Colors.grey[500]!;
  static Color grey600 = Colors.grey[600]!;
  static Color grey700 = Colors.grey[700]!;
  static Color grey800 = Colors.grey[800]!;
  static Color grey900 = Colors.grey[900]!;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get category color by ID
  static Color getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return categoryFood;
      case 2:
        return categoryTransport;
      case 3:
        return successGreen; // Salary/Income
      case 4:
        return categoryBills;
      case 5:
        return categoryShopping;
      case 6:
        return categoryHealth;
      case 7:
        return categoryEducation;
      default:
        return textTertiary;
    }
  }

  /// Get transaction type color (income/expense)
  static Color getTransactionTypeColor(int type) {
    return type == 0 ? successGreen : errorRed;
  }
}
