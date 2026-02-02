import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';

class MonthlyReportDialog extends StatelessWidget {
  final DateTime month;
  final double income;
  final double expense;

  const MonthlyReportDialog({
    super.key,
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final savings = income - expense;
    final isPositive = savings >= 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFF2E7D32),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Tổng kết tháng ${month.month}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tình hình tài chính hiện tại',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Thu nhập',
                    income,
                    const Color(0xFF00E676),
                    const Color(0xFFE8F5E9),
                    currencyFormat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Chi tiêu',
                    expense,
                    const Color(0xFFFF5252),
                    const Color(0xFFFFEBEE),
                    currencyFormat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Savings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPositive
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiết kiệm',
                        style: TextStyle(
                          fontSize: 13,
                          color: isPositive
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFC62828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(savings),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isPositive
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFC62828),
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    double amount,
    Color color,
    Color bgColor,
    NumberFormat format,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            format.format(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color.withOpacity(0.8), // Slightly darker for readability
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
