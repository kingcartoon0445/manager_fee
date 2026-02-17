import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../blocs/report/report_bloc.dart';
import '../../blocs/report/report_event.dart';
import '../../blocs/report/report_state.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../core/app_colors.dart';
import '../../../core/category_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/responsive_layout.dart';
import '../surplus_history_page.dart';
import 'mobile/reports_page_mobile.dart';
import 'ipad/reports_page_ipad.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportType _viewMode = ReportType.daily;
  DateTime selectedDate = DateTime.now(); // Default to today
  int _transactionType = 1; // 0: Income, 1: Expense

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context
        .read<ReportBloc>()
        .add(LoadReportEvent(selectedDate, viewMode: _viewMode));
  }

  void _changeDate(int offset) {
    setState(() {
      if (_viewMode == ReportType.daily) {
        // Navigate by DAY
        selectedDate = selectedDate.add(Duration(days: offset));
      } else {
        // Navigate by MONTH
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month + offset,
          1, // First day of month
        );
      }
    });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            _transactionType == 1 ? AppColors.errorRed : AppColors.successGreen,
        title: const Text('Báo cáo thống kê',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Lịch sử tích lũy',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SurplusHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final body = Column(
      children: [
        _buildHeader(),
        Expanded(
          child: BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state is ReportLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ReportLoaded) {
                final filteredTransactions = state.transactions
                    .where((t) => t.type == _transactionType)
                    .toList();

                if (filteredTransactions.isEmpty) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty,
                          size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("Chưa có dữ liệu",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadReport(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(filteredTransactions),
                          const SizedBox(height: 24),
                          if (_viewMode == ReportType.daily)
                            _buildDailyView(
                                filteredTransactions, state.categories)
                          else
                            _buildMonthlyView(
                                filteredTransactions, state.categories),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is ReportError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );

    if (isTablet) {
      return ReportsPageIpad(child: body);
    }
    return ReportsPageMobile(child: body);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: BoxDecoration(
        color: _transactionType == 1
            ? AppColors.errorRed
            : AppColors.successGreen, // Dynamic Color
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: (_transactionType == 1
                    ? AppColors.errorRed
                    : AppColors.successGreen)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Income / Expense Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTypeToggle("Thu Nhập", 0),
                _buildTypeToggle("Chi Tiêu", 1),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Date Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
                onPressed: () => _changeDate(-1),
              ),
              Column(
                children: [
                  // View Mode Chips
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildViewModeChip("Ngày", ReportType.daily),
                      const SizedBox(width: 8),
                      _buildViewModeChip("Tháng", ReportType.monthly),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _viewMode == ReportType.daily
                        ? DateFormat('dd/MM/yyyy').format(selectedDate)
                        : DateFormat('MM/yyyy').format(selectedDate),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  )
                      .animate(key: ValueKey(selectedDate))
                      .fadeIn()
                      .slideY(begin: 0.3, end: 0),
                  Text(
                    _viewMode == ReportType.daily
                        ? _getWeekdayName(selectedDate)
                        : "Tháng ${selectedDate.month}",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 20),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(String title, int type) {
    final isSelected = _transactionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _transactionType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? (_transactionType == 1
                      ? AppColors.errorRed
                      : AppColors.successGreen)
                  : Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeChip(String title, ReportType mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = mode;
          if (mode == ReportType.monthly) {
            selectedDate = DateTime(selectedDate.year, selectedDate.month, 1);
          }
        });
        _loadReport();
      },
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return 'Thứ ${weekdays[date.weekday % 7]}';
  }

  Widget _buildSummaryCard(List<Transaction> transactions) {
    final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final color =
        _transactionType == 1 ? AppColors.errorRed : AppColors.successGreen;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text(
            _transactionType == 1 ? "Tổng Chi Tiêu" : "Tổng Thu Nhập",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatCompact(total),
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -1),
          )
              .animate(key: ValueKey(total))
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          if (_viewMode == ReportType.monthly) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Trung bình ngày: ${CurrencyFormatter.formatCompact(total / DateTime(selectedDate.year, selectedDate.month + 1, 0).day)}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOut);
  }

  // DAILY VIEW: Show category breakdown
  Widget _buildDailyView(List<Transaction> expenses, List<dynamic> categories) {
    // Group by category
    final Map<int, double> categorySums = {};
    final Map<int, List<Transaction>> categoryTransactions = {};

    for (var t in expenses) {
      categorySums[t.categoryId] = (categorySums[t.categoryId] ?? 0) + t.amount;
      categoryTransactions[t.categoryId] =
          (categoryTransactions[t.categoryId] ?? [])..add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Phân bổ chi tiêu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: _buildPieChart(categorySums, categories),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Transaction List by Category
        _buildTransactionList(categoryTransactions, categories),
      ],
    );
  }

  // MONTHLY VIEW: Show daily trend + category summary
  Widget _buildMonthlyView(
      List<Transaction> expenses, List<dynamic> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar Chart - Daily Expenses
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Xu hướng chi tiêu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: _buildDailyBarChart(expenses),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Pie Chart - Category Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Phân bổ theo danh mục",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: _buildCategorySummaryPieChart(expenses, categories),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Top Categories
        _buildTopCategories(expenses, categories),
      ],
    );
  }

  Widget _buildPieChart(
      Map<int, double> categorySums, List<dynamic> categories) {
    if (categorySums.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    final total = categorySums.values.fold<double>(0, (sum, val) => sum + val);
    int touchedIndex = -1;

    return StatefulBuilder(
      builder: (context, setState) {
        final sections =
            categorySums.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final percentage = (e.value / total) * 100;
          final category = categories.firstWhere(
            (c) => c.id == e.key,
            orElse: () => const Category(
                id: -1, name: "Danh mục khác", type: 1, icon: ""),
          );
          final color = category.colorValue != null
              ? Color(category.colorValue!)
              : CategoryIcons.getColorByName(category.name);
          final isTouched = index == touchedIndex;
          final radius = isTouched ? 70.0 : 60.0;

          return PieChartSectionData(
            value: percentage,
            title: isTouched
                ? '${category.name}\n${CurrencyFormatter.formatCompact(e.value)}'
                : '${percentage.toStringAsFixed(0)}%',
            titleStyle: TextStyle(
              fontSize: isTouched ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            color: color,
            radius: radius,
          );
        }).toList();

        return PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 50, // Donut Style
            sectionsSpace: 4,
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
      },
    );
  }

  Widget _buildCategorySummaryPieChart(
      List<Transaction> expenses, List<dynamic> categories) {
    final Map<int, double> categorySums = {};
    for (var t in expenses) {
      categorySums[t.categoryId] = (categorySums[t.categoryId] ?? 0) + t.amount;
    }
    return _buildPieChart(categorySums, categories);
  }

  Widget _buildDailyBarChart(List<Transaction> expenses) {
    final Map<int, double> dailySums = {};
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    for (var t in expenses) {
      dailySums[t.date.day] = (dailySums[t.date.day] ?? 0) + t.amount;
    }

    final maxAmount = dailySums.isEmpty
        ? 100.0
        : dailySums.values.reduce((a, b) => a > b ? a : b) * 1.2;

    final barGroups = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final amount = dailySums[day] ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: _transactionType == 1
                ? AppColors.errorRed
                : AppColors.successGreen,
            width: 6,
            borderRadius: BorderRadius.circular(3),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxAmount,
              color: Colors.grey.withOpacity(0.1),
            ),
          )
        ],
      );
    });

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0 || value.toInt() == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
      ),
    );
  }

  Widget _buildTransactionList(Map<int, List<Transaction>> categoryTransactions,
      List<dynamic> categories) {
    final sortedCategories = categoryTransactions.entries.toList()
      ..sort((a, b) {
        final sumA = a.value.fold<double>(0, (sum, t) => sum + t.amount);
        final sumB = b.value.fold<double>(0, (sum, t) => sum + t.amount);
        return sumB.compareTo(sumA);
      });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  "Chi tiết giao dịch",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final entry = sortedCategories[index];
              final category = categories.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => const Category(
                    id: -1, name: "Danh mục khác", type: 1, icon: ""),
              );
              final transactions = entry.value;
              final total =
                  transactions.fold<double>(0, (sum, t) => sum + t.amount);

              final catColor = category.colorValue != null
                  ? Color(category.colorValue!)
                  : CategoryIcons.getColorByName(category.name);

              Widget iconWidget = Text(
                category.icon ?? '📁',
                style: const TextStyle(fontSize: 20),
              );

              if (category.id != null) {
                final staticMap = CategoryIcons.getCategoryById(category.id!);
                if (staticMap['id'] == category.id) {
                  final iconData = staticMap['icon'] as IconData;
                  if (category.icon ==
                      String.fromCharCode(iconData.codePoint)) {
                    iconWidget = Icon(iconData, color: catColor, size: 24);
                  }
                }
              }

              return ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: catColor.withOpacity(0.15),
                  child: iconWidget,
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${transactions.length} giao dịch'),
                trailing: Text(
                  CurrencyFormatter.formatCompact(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                children: transactions.map((t) {
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                    title: Text(t.note ?? 'Không có ghi chú'),
                    subtitle: Text(DateFormat('HH:mm').format(t.date)),
                    trailing: Text(
                      CurrencyFormatter.formatCompact(t.amount),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(
      List<Transaction> expenses, List<dynamic> categories) {
    final Map<int, double> categorySums = {};
    for (var t in expenses) {
      categorySums[t.categoryId] = (categorySums[t.categoryId] ?? 0) + t.amount;
    }

    final sortedEntries = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  "Top danh mục",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.take(5).length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final category = categories.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => const Category(
                    id: -1, name: "Danh mục khác", type: 1, icon: ""),
              );

              final catColor = category.colorValue != null
                  ? Color(category.colorValue!)
                  : CategoryIcons.getColorByName(category.name);

              Widget iconWidget = Text(
                category.icon ?? '📁',
                style: const TextStyle(fontSize: 20),
              );

              if (category.id != null) {
                final staticMap = CategoryIcons.getCategoryById(category.id!);
                if (staticMap['id'] == category.id) {
                  final iconData = staticMap['icon'] as IconData;
                  if (category.icon ==
                      String.fromCharCode(iconData.codePoint)) {
                    iconWidget = Icon(iconData, color: catColor, size: 24);
                  }
                }
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: catColor.withOpacity(0.15),
                  child: iconWidget,
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  CurrencyFormatter.formatCompact(entry.value),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
