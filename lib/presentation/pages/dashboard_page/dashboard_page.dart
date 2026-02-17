import 'package:peadget/core/app_colors.dart';
import 'package:peadget/core/category_icons.dart';
import 'package:peadget/core/responsive_layout.dart';
import 'package:peadget/presentation/blocs/transaction/transaction_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../blocs/budget/budget_event.dart';
import '../../blocs/budget/budget_state.dart';

import '../../../injection_container.dart' as di;
import '../../widgets/add_transaction_modal.dart';
import '../../widgets/quick_shopping_modal.dart';
import '../../widgets/quick_action_banner.dart';
import '../../../core/animations.dart';
import '../../../core/thousand_separator_formatter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';
import '../../../core/utils/financial_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/monthly_report_dialog.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../data/models/monthly_surplus_model.dart';
import '../../../data/datasources/isar_service.dart';
import '../../pages/ai_chat/ai_chat_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'mobile/dashboard_page_mobile.dart';
import 'ipad/dashboard_page_ipad.dart';

enum RightPanelMode { addTransaction, quickShop, history, aiChat }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _currentMonth = DateTime.now();
  double _initialBalance = 0;
  RightPanelMode _rightPanelMode = RightPanelMode.addTransaction;

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<BudgetBloc>().add(LoadBudgets());
  }

  void _loadData() async {
    context.read<TransactionBloc>().add(LoadTransactions());
    final prefs = di.sl<SharedPreferences>();
    // Reload prefs in case it changed
    await prefs.reload();
    setState(() {
      _initialBalance = prefs.getDouble('initial_balance') ?? 0;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final useTabletLayout = isTablet && isLandscape;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Very light cool grey/white
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: BlocConsumer<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionLoaded) {
                _checkAndShowMonthlyReport(context, state.transactions);
              }
            },
            builder: (context, txState) {
              double closingBalance = 0;
              double income = 0;
              double expense = 0;
              List<dynamic> transactions = [];
              List<Category> categories = [];

              if (txState is TransactionLoaded) {
                final allTx = txState.transactions;

                income =
                    FinancialCalculator.calculateIncome(allTx, _currentMonth);
                expense =
                    FinancialCalculator.calculateExpense(allTx, _currentMonth);
                closingBalance = FinancialCalculator.calculateClosingBalance(
                    allTx, _currentMonth, _initialBalance);

                // Filter transactions for current month list display
                transactions = allTx
                    .where((t) =>
                        t.date.year == _currentMonth.year &&
                        t.date.month == _currentMonth.month)
                    .toList();
                transactions.sort((a, b) => b.date.compareTo(a.date));
                categories = txState.categories;
              }

              final currencyFormat = NumberFormat.currency(
                  locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

              // Calculate Net Available
              double netAvailable = 0;
              final budgetState = context.watch<BudgetBloc>().state;
              if (budgetState is BudgetLoaded && txState is TransactionLoaded) {
                netAvailable = FinancialCalculator.calculateNetAvailable(
                    closingBalance, budgetState.budgets, txState.transactions);
              } else {
                // Fallback if data not fully loaded, though closingBalance is 0 initially
                netAvailable = closingBalance;
              }

              // Pre-build shared widget sections
              final header = _buildHeader();
              final balanceSection = _buildBalanceSection(closingBalance,
                  netAvailable, income, expense, currencyFormat);
              final quickActionBanner = _buildQuickActionBanner(context);
              final netFlow = _buildNetFlow(income - expense, currencyFormat);
              final budgetSection = _buildBudgetSection(transactions);
              final dailyExpenseDetails = _buildDailyExpenseDetails(
                  transactions, categories, currencyFormat);

              return RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                },
                child: useTabletLayout
                    ? DashboardPageIpad(
                        header: header,
                        balanceSection: balanceSection,
                        quickActionBanner: quickActionBanner,
                        netFlow: netFlow,
                        budgetSection: budgetSection,
                        dailyExpenseDetails: dailyExpenseDetails,
                        rightPanelMode: _rightPanelMode,
                        onSwitchMode: (mode) {
                          setState(() {
                            _rightPanelMode = mode;
                          });
                        },
                        onResetRightPanel: () {
                          setState(() {
                            _rightPanelMode = RightPanelMode.addTransaction;
                          });
                        },
                      )
                    : DashboardPageMobile(
                        header: header,
                        balanceSection: balanceSection,
                        quickActionBanner: quickActionBanner,
                        netFlow: netFlow,
                        budgetSection: budgetSection,
                        dailyExpenseDetails: dailyExpenseDetails,
                      ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: !useTabletLayout
          ? ScaleAnimation(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddTransactionModal());
              },
              child: FloatingActionButton(
                onPressed: null,
                backgroundColor: const Color(0xFF2962FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            )
          : (_rightPanelMode == RightPanelMode.aiChat
              ? null
              : ScaleAnimation(
                  onTap: () {
                    setState(() {
                      _rightPanelMode = RightPanelMode.aiChat;
                    });
                  },
                  child: FloatingActionButton(
                    onPressed: null,
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 30),
                  ),
                )),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('THÁNG HIỆN TẠI',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Row(
              children: [
                InkWell(
                  onTap: () => _changeMonth(-1),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0, bottom: 8, top: 8),
                    child: Icon(Icons.chevron_left, size: 20),
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM').format(_currentMonth),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                InkWell(
                  onTap: () => _changeMonth(1),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8, top: 8),
                    child: Icon(Icons.chevron_right, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiChatPage()),
                );
              },
              icon: const Icon(Icons.auto_awesome, color: Color(0xFF2962FF))
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(
                      begin: 1.0,
                      end: 1.15,
                      duration: 1.5.seconds,
                      curve: Curves.easeInOut), // Magic Icon, Breathing
              tooltip: 'Trợ lý AI',
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showTemporaryReport(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('HÔM NAY',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2962FF)), // Deep Blue consistent
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceSection(double totalBalance, double netAvailable,
      double income, double expense, NumberFormat format) {
    return Column(
      children: [
        // Total Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2962FF), Color(0xFF00B0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF2962FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(width: 10),
                  Text('TỔNG TÀI SẢN',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  const SizedBox(width: 6),
                  _buildInfoTooltip('Tổng tiền mặt hiện có trong ví.'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                format.format(totalBalance),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.savings_outlined,
                        color: Colors.white.withOpacity(0.9), size: 16),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Tổng tiền (Khả dụng)',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(width: 4),
                            _buildInfoTooltip(
                                'Số tiền còn lại có thể chi tiêu (sau khi trừ ngân sách dự kiến).',
                                size: 14),
                          ],
                        ),
                        Text(
                          format.format(netAvailable),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Income / Expense Row
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                  'Tổng Thu',
                  income,
                  Icons.arrow_downward,
                  const Color(0xFF00E676), // Green
                  const Color(0xFFE8F5E9), // Light Green
                  format,
                  'Tổng thu nhập thực tế trong tháng.'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMiniStatCard(
                  'Tổng Chi',
                  expense,
                  Icons.arrow_upward,
                  const Color(0xFFFF5252), // Red
                  const Color(0xFFFFEBEE), // Light Red
                  format,
                  'Tổng chi tiêu thực tế trong tháng.'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(
      String title,
      double amount,
      IconData icon,
      Color iconColor,
      Color bgColor,
      NumberFormat format,
      String tooltipMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFE0E0E0).withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              _buildInfoTooltip(tooltipMessage,
                  color: Colors.grey[400]!, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: iconColor == const Color(0xFFFF5252)
                  ? const Color(0xFFC62828)
                  : const Color(0xFF2E7D32),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTooltip(String message,
      {Color color = Colors.white70, double size = 16}) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF263238).withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 13),
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Touch target padding
        child: Icon(Icons.info_outline, size: size, color: color),
      ),
    );
  }

  Widget _buildQuickActionBanner(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final useTabletLayout = isTablet && isLandscape;

    return QuickActionBanner(
      onTap: () {
        if (useTabletLayout) {
          setState(() {
            _rightPanelMode = RightPanelMode.quickShop;
          });
        } else {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const QuickShoppingModal());
        }
      },
    );
  }

  Widget _buildNetFlow(double netFlow, NumberFormat format) {
    final isPositive = netFlow >= 0;
    Color bg = isPositive
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE); // Green 50 : Red 50
    Color text = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: text.withOpacity(0.05), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text('Dòng tiền Thu - Chi',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
                const SizedBox(width: 6),
                _buildInfoTooltip(
                    'Chênh lệch giữa Thu và Chi. (Dương = Dư, Âm = Thâm hụt)',
                    color: Colors.grey[500]!),
              ],
            ),
          ),
          Text(CurrencyFormatter.formatCompact(netFlow),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: text, fontWeight: FontWeight.w800, fontSize: 20)),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildDailyExpenseDetails(List<dynamic> transactions,
      List<Category> categories, NumberFormat format) {
    // ... (rest of logic unchanged until mapping) ...
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final selectedMonth = DateTime(_currentMonth.year, _currentMonth.month);

    // Determine which day to show
    final DateTime targetDate;
    final bool isCurrentMonth = selectedMonth.isAtSameMomentAs(currentMonth);

    if (isCurrentMonth) {
      // Current month: show today
      targetDate = DateTime(now.year, now.month, now.day);
    } else {
      // Past/future month: show last day of that month
      final lastDayOfMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      targetDate =
          DateTime(_currentMonth.year, _currentMonth.month, lastDayOfMonth);
    }

    // Filter expenses for target date
    final dayExpenses = transactions.where((t) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      return t.type == 1 && txDate.isAtSameMomentAs(targetDate);
    }).toList();

    // Sort by time (most recent first)
    dayExpenses.sort((a, b) => b.date.compareTo(a.date));

    // Calculate total
    final totalDay = dayExpenses.fold(0.0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFFF6F00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentMonth
                          ? 'Chi tiêu hôm nay'
                          : 'Chi tiêu ngày ${targetDate.day}',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${targetDate.day}/${targetDate.month}/${targetDate.year}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Total badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tổng',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCompact(totalDay),
                      style: const TextStyle(
                        color: Color(0xFFFF6F00),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // Transaction list
        if (dayExpenses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isCurrentMonth
                        ? 'Chưa có chi tiêu nào hôm nay'
                        : 'Không có chi tiêu ngày ${targetDate.day}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: dayExpenses
                .map((tx) {
                  final time =
                      '${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}';

                  // Get category color FROM DB
                  final cat = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => Category(
                        id: 0,
                        name: 'Danh mục khác',
                        type: 1,
                        icon: '?',
                        colorValue: Colors.grey.value),
                  );

                  final categoryColor = cat.colorValue != null
                      ? Color(cat.colorValue!)
                      : CategoryIcons.getColorByName(cat.name);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Time
                        SizedBox(
                          width: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                time,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Note
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.note != "" ? tx.note : 'Không có ghi chú',
                                style: TextStyle(
                                  // fontStyle: tx.note != ""
                                  //     ? FontStyle.normal
                                  //     : FontStyle.italic,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (tx.tags != null && tx.tags!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Wrap(
                                    spacing: 4,
                                    children: tx.tags!.map<Widget>((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: categoryColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: TextStyle(
                                            color:
                                                categoryColor.withOpacity(0.8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Amount
                        Text(
                          CurrencyFormatter.formatCompact(tx.amount),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList()
                .animate(interval: 50.ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1, curve: Curves.easeOut),
          ),
      ],
    );
  }

  Widget _buildBudgetSection(List<dynamic> transactions) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state is BudgetLoaded && state.budgets.isNotEmpty) {
          return Column(
            children: state.budgets.map((b) {
              double spent = 0;
              for (var t in transactions) {
                if (t.type == 1 && t.budgetId == b.id) {
                  spent += t.amount;
                }
              }
              double progress = (b.amount > 0) ? (spent / b.amount) : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFE0E0E0).withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0), // Orange 50
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.track_changes,
                              color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Hạn Mức Chi Tiêu',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color(0xFF263238))),
                        const Spacer(),
                        InkWell(
                          onTap: () => _showEditBudgetDialog(context, b, spent),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2962FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF2962FF)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(
                                Icons
                                    .edit, // Changed to Edit icon for better UX? Or keep Add? User said "+"
                                color: Colors.white,
                                size: 16),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(b.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87)),
                        Text(
                          '${CurrencyFormatter.formatCompact(spent)} / ${CurrencyFormatter.formatCompact(b.amount)}',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress > 1 ? 1 : progress,
                        minHeight: 10,
                        color: progress > 0.8
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF00E676),
                        backgroundColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showEditBudgetDialog(
      BuildContext context, Budget budget, double currentSpent) {
    final controller = TextEditingController(
        text: NumberFormat.decimalPattern('vi').format(budget.amount));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Điều chỉnh hạn mức',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Hạn mức hiện tại: ${CurrencyFormatter.formatCompact(budget.amount)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Đã chi: ${CurrencyFormatter.formatCompact(currentSpent)}',
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Hạn mức mới',
                border: OutlineInputBorder(),
                suffixText: 'VND',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final newVal =
                  ThousandsSeparatorInputFormatter.parseFormattedNumber(
                      controller.text);
              if (newVal == null) return;

              if (newVal <= currentSpent) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Hạn mức mới phải lớn hơn số tiền đã chi (${CurrencyFormatter.formatCompact(currentSpent)})!'),
                    backgroundColor: Colors.red));
                return;
              }

              context
                  .read<BudgetBloc>()
                  .add(UpdateBudgetEvent(budget.copyWith(amount: newVal)));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã cập nhật hạn mức thành công!'),
                backgroundColor: Colors.green,
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                foregroundColor: Colors.white),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndShowMonthlyReport(
      BuildContext context, List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    // Target last month
    final lastMonth = DateTime(now.year, now.month - 1);
    final key = 'monthly_report_shown_${lastMonth.year}_${lastMonth.month}';

    // Uncomment to test:
    // await prefs.remove(key);

    if (prefs.getBool(key) ?? false) return;

    // Calculate stats for last month
    double income =
        FinancialCalculator.calculateIncome(transactions, lastMonth);
    double expense =
        FinancialCalculator.calculateExpense(transactions, lastMonth);

    // Only show if there is data
    if (income > 0 || expense > 0) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => MonthlyReportDialog(
            month: lastMonth,
            income: income,
            expense: expense,
          ),
        );
        await prefs.setBool(key, true);
      }
    }

    // Check for Monthly Surplus (New Feature)
    if (context.mounted) {
      await _checkMonthlySurplus(context, transactions);
    }
  }

  void _showTemporaryReport(BuildContext context) {
    final state = context.read<TransactionBloc>().state;
    if (state is TransactionLoaded) {
      final now = DateTime.now();
      // Calculate for current month, but filtering up to "now" is handled by calc
      // methods implicitly if we pass the whole list? No, income/expense methods
      // usually take the month and filter by it.
      // We want to show "Temporary" report which suggests current status.
      // Using the standard calculations for the current month is correct.

      double income =
          FinancialCalculator.calculateIncome(state.transactions, now);
      double expense =
          FinancialCalculator.calculateExpense(state.transactions, now);

      showDialog(
        context: context,
        builder: (context) => MonthlyReportDialog(
          month: now,
          income: income,
          expense: expense,
        ),
      );
    }
  }

  Future<void> _checkMonthlySurplus(
      BuildContext context, List<Transaction> transactions) async {
    final appSettingsRepo = di.sl<AppSettingsRepository>();
    final settings = await appSettingsRepo.getAppSettings();

    if (settings == null) return;

    final now = DateTime.now();
    // We want to check the previous month relative to "now".
    // Or if lastClosed is way back, we might check the oldest unclosed month?
    // For simplicity, let's just check the IMMEDIATELY preceding month.
    // If the user hasn't opened the app for 3 months, we only handle the last month?
    // User requirement: "when end app ... surplus ... last month".
    // Let's check Previous Month.
    final prevMonth = DateTime(now.year, now.month - 1);

    final lastClosed = settings.lastClosedMonth;

    // Check if we need to close 'prevMonth'
    // Condition:
    // 1. lastClosed is null -> First time run? Maybe we shouldn't trigger immediately if install is fresh?
    //    But if they have data for prev month, we should?
    //    Let's assume if null, we check prevMonth.
    // 2. lastClosed is before prevMonth (e.g. last closed is Aug, now is Oct, prev is Sept. Aug < Sept).
    bool needsClosing = false;
    if (lastClosed == null) {
      // Check if we have transactions for prevMonth to avoid annoying fresh users
      final hasData = transactions.any((t) =>
          t.date.year == prevMonth.year && t.date.month == prevMonth.month);
      if (hasData) needsClosing = true;
    } else {
      // If lastClosed is BEFORE prevMonth (ignoring day)
      final lastClosedMonthStart = DateTime(lastClosed.year, lastClosed.month);
      if (lastClosedMonthStart.isBefore(prevMonth)) {
        needsClosing = true;
      }
    }

    if (!needsClosing) return;

    // Calculate Surplus
    double income =
        FinancialCalculator.calculateIncome(transactions, prevMonth);
    double expense =
        FinancialCalculator.calculateExpense(transactions, prevMonth);
    double surplus = income - expense;

    if (surplus > 0) {
      if (context.mounted) {
        await _showSurplusActionDialog(
            context, prevMonth, surplus, income, expense);
      }
    } else {
      // If no surplus (negative or zero), we might just mark it as closed quietly?
      // Or show a report saying "You broke even / Overspent"?
      // For now, let's just mark it closed to avoid checking again.
      // Or maybe MonthlyReportDialog already handles the "Report" aspect.
      // Let's just update lastClosedMonth to skip this month in future checks.
      final newSettings = AppSettings(
        id: settings.id,
        hasCompletedOnboarding: settings.hasCompletedOnboarding,
        onboardingCompletedAt: settings.onboardingCompletedAt,
        initialBalance: settings.initialBalance,
        lastClosedMonth: prevMonth,
      );
      await appSettingsRepo.saveAppSettings(newSettings);
    }
  }

  Future<void> _showSurplusActionDialog(BuildContext context, DateTime month,
      double surplus, double income, double expense) async {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.savings_outlined, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Số dư tháng ${month.month}/${month.year}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chúc mừng! Tháng vừa rồi bạn đã dư:',
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            Text(currencyFormat.format(surplus),
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            SizedBox(height: 20),
            Text('Bạn muốn làm gì với khoản tiền này?',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark as Closed but do nothing (Keep in Available)
              _updateLastClosedMonth(month);
              Navigator.pop(context);
            },
            child: Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rolloverSurplus(context, month, surplus, income, expense);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: Text('Dùng tiếp (Cộng Ngân Sách)'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSurplus(context, month, surplus, income, expense);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: Text('Cất đi (Tiết Kiệm)'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLastClosedMonth(DateTime month) async {
    final repo = di.sl<AppSettingsRepository>();
    final settings = await repo.getAppSettings();
    if (settings != null) {
      await repo.saveAppSettings(AppSettings(
        id: settings.id,
        hasCompletedOnboarding: settings.hasCompletedOnboarding,
        onboardingCompletedAt: settings.onboardingCompletedAt,
        initialBalance: settings.initialBalance,
        lastClosedMonth: month,
      ));
    }
  }

  Future<void> _recordHistory(DateTime month, double surplus, int action,
      double income, double expense) async {
    final isarService = di.sl<IsarService>();
    final isar = await isarService.db;

    // Need to calculate income/expense again or pass it?
    // For simplicity, let's just record surplus for now.
    // Ideally pass income/expense to this method.

    final newItem = MonthlySurplusModel()
      ..monthYear = month
      ..surplus = surplus
      ..action = action
      ..expense = expense
      ..income = income
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.monthlySurplusModels.put(newItem);
    });
  }

  Future<void> _saveSurplus(BuildContext context, DateTime month,
      double surplus, double income, double expense) async {
    // Show Add Transaction Modal pre-filled
    // ID 0 for category usually means "Other" or needs specific ID.
    // Let's try to find "Tiết kiệm" or use a default.
    // For now passing 0 and note.

    // We need to mark as closed AFTER user confirms adding transaction?
    // Or mark now?
    // Better to mark now, and let user add transaction.
    await _updateLastClosedMonth(month);
    await _recordHistory(month, surplus, 1, income, expense); // 1 = Saved

    if (context.mounted) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddTransactionModal(
                initialAmount: surplus,
                initialNote: 'Khoản dư tháng ${month.month}/${month.year}',
                initialDate: DateTime.now(), // Today (start of new month)
                // initialIsExpense: true // Default is expense
              ));
    }
  }

  Future<void> _rolloverSurplus(BuildContext context, DateTime month,
      double surplus, double income, double expense) async {
    // Increase Budget of THIS month
    final now = DateTime.now();
    final budgetBloc = context.read<BudgetBloc>();

    // Check if we have budgets for this month?
    // BudgetBloc state should have them.
    final state = budgetBloc.state;
    if (state is BudgetLoaded && state.budgets.isNotEmpty) {
      // Logic: Do we add to a "General" budget or split?
      // Simplest: Ask user which budget to increase? Or create a "Rollover" budget?
      // Or just add to the first one?
      // User request: "lưu số tiền đó ... để dùng cho tháng tiếp theo".
      // "cho người dùng lưu số tiền đó va 1 khoản".
      // Let's create a NEW Budget or Add to Total?
      // If we create a budget named "Số dư tháng trước" with amount = surplus?
      // That allows spending against it.

      // Creating a new budget seems appropriate.
      final newBudget = Budget(
          id: DateTime.now().millisecondsSinceEpoch, // Temp ID
          name: 'Số dư tháng trước',
          amount: surplus,
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0));

      budgetBloc.add(AddBudgetEvent(newBudget));

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ngân sách "Số dư tháng trước"!')));
    } else {
      // No budgets exist. Create one.
      final newBudget = Budget(
          id: DateTime.now().millisecondsSinceEpoch,
          name: 'Số dư tháng trước',
          amount: surplus,
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0)
          // categoryId: null // General
          );
      budgetBloc.add(AddBudgetEvent(newBudget));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đã tạo ngân sách từ số dư!')));
    }

    await _updateLastClosedMonth(month);
    await _recordHistory(month, surplus, 2, income, expense); // 2 = Rollover
  }
}
