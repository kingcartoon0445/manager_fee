import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../data/datasources/isar_service.dart';
import '../../data/models/monthly_surplus_model.dart';
import '../../injection_container.dart' as di;
// import '../../core/utils/currency_formatter.dart';

class SurplusHistoryPage extends StatefulWidget {
  const SurplusHistoryPage({super.key});

  @override
  State<SurplusHistoryPage> createState() => _SurplusHistoryPageState();
}

class _SurplusHistoryPageState extends State<SurplusHistoryPage> {
  List<MonthlySurplusModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final isarService = di.sl<IsarService>();
    final isar = await isarService.db;
    final data =
        await isar.monthlySurplusModels.where().sortByMonthYearDesc().findAll();

    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text('Lịch sử dư hàng tháng',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Chưa có dữ liệu lịch sử',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return _buildHistoryItem(item);
                  },
                ),
    );
  }

  Widget _buildHistoryItem(MonthlySurplusModel item) {
    String actionText = '';
    Color actionColor = Colors.grey;
    IconData actionIcon = Icons.help_outline;

    switch (item.action) {
      case 1:
        actionText = 'Đã cất đi (Tiết kiệm)';
        actionColor = Colors.green;
        actionIcon = Icons.savings;
        break;
      case 2:
        actionText = 'Đã dùng tiếp (Cộng ngân sách)';
        actionColor = Colors.blue;
        actionIcon = Icons.add_circle;
        break;
      default:
        actionText = 'Chưa xử lý / Để sau';
        actionColor = Colors.orange;
        actionIcon = Icons.watch_later;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng ${item.monthYear.month}/${item.monthYear.year}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(actionIcon, size: 14, color: actionColor),
                    const SizedBox(width: 4),
                    Text(
                      actionText,
                      style: TextStyle(
                          color: actionColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số dư',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                        .format(item.surplus),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
              // We could show Income/Expense if we stored them populated (default 0 in model)
              // If they remain 0, maybe hide?
              // The logic I wrote only calculated surplus, I didn't verify if I populated income/expense.
              // Let's check _recordHistory in DashboardPage again.
            ],
          ),
        ],
      ),
    );
  }
}
