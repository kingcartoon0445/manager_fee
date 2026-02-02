import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Formats a number to a compact string (e.g., 1k, 1M).
  ///
  /// - [amount]: The amount to format.
  /// - [locale]: Optional locale (currently used for basic number formatting fallback).
  ///
  /// Examples:
  /// 1000 -> 1k
  /// 1500 -> 1.5k
  /// 1000000 -> 1M
  static String formatCompact(double amount) {
    if (amount == 0) return '0';

    final isNegative = amount < 0;
    double absAmount = amount.abs();
    String suffix = '';
    double formattedAmount = absAmount;

    if (absAmount >= 1000000000) {
      formattedAmount = absAmount / 1000000000;
      suffix = 'B';
    } else if (absAmount >= 1000000) {
      formattedAmount = absAmount / 1000000;
      suffix = 'M';
    } else if (absAmount >= 1000) {
      formattedAmount = absAmount / 1000;
      suffix = 'k';
    }

    // Use NumberFormat to handle decimal places nicely (max 2 decimal places, remove trailing zeros)
    final formatter = NumberFormat("#,##0.##", "en_US");
    String result = formatter.format(formattedAmount);

    return '${isNegative ? '-' : ''}$result$suffix';
  }

  static String format(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}
