import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../widgets/add_transaction_modal.dart';
import '../../../core/animations.dart';
import '../../../core/category_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/responsive_layout.dart';
import 'mobile/transaction_page_mobile.dart';
import 'ipad/transaction_page_ipad.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Sổ Giao Dịch'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 22),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.grey),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: ScaleAnimation(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionModal(),
          );
        },
        child: FloatingActionButton(
          onPressed: null,
          backgroundColor: const Color(0xFF2962FF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final body = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THÁNG HIỆN TẠI',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _changeMonth(-1),
                        child: const Icon(Icons.chevron_left, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy-MM').format(_selectedMonth),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _changeMonth(1),
                        child: const Icon(Icons.chevron_right, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: const Color(0xFFE3F2FD),
                child: const Text('GD',
                    style: TextStyle(
                        color: Color(0xFF2962FF), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoaded) {
                final transactions = state.transactions
                    .where((t) =>
                        t.date.year == _selectedMonth.year &&
                        t.date.month == _selectedMonth.month)
                    .toList();
                transactions.sort((a, b) => b.date.compareTo(a.date));
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Không có giao dịch nào',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                final Map<String, List<dynamic>> groupedTransactions = {};
                for (var t in transactions) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(t.date);
                  if (groupedTransactions[dateKey] == null) {
                    groupedTransactions[dateKey] = [];
                  }
                  groupedTransactions[dateKey]!.add(t);
                }
                final sortedDateKeys = groupedTransactions.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: sortedDateKeys.length,
                  itemBuilder: (context, index) {
                    final dateKey = sortedDateKeys[index];
                    final dayTransactions = groupedTransactions[dateKey]!;
                    final date = DateTime.parse(dateKey);
                    final isToday = DateUtils.isSameDay(date, DateTime.now());
                    double dailyTotal = 0;
                    for (var t in dayTransactions) {
                      if (t.type == 0) {
                        dailyTotal += t.amount;
                      } else {
                        dailyTotal -= t.amount;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isToday
                                            ? 'Hôm nay'
                                            : DateFormat('EEEE', 'vi')
                                                .format(date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Tháng ${date.month}. ${date.year}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                dailyTotal >= 0
                                    ? '+${CurrencyFormatter.formatCompact(dailyTotal)}'
                                    : CurrencyFormatter.formatCompact(
                                        dailyTotal),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: dailyTotal >= 0
                                      ? const Color(0xFF00E676)
                                      : const Color(0xFF1A1A1A),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...dayTransactions.map((t) {
                          final isIncome = t.type == 0;
                          final cat = state.categories.firstWhere(
                            (c) => c.id == t.categoryId,
                            orElse: () =>
                                CategoryIcons.toDomain(CategoryIcons.other),
                          );
                          final catColor = cat.colorValue != null
                              ? Color(cat.colorValue!)
                              : CategoryIcons.getColorByName(cat.name);
                          Widget iconWidget = Text(
                            cat.icon ?? '',
                            style: const TextStyle(fontSize: 24),
                          );
                          if (cat.id != null) {
                            final staticMap =
                                CategoryIcons.getCategoryById(cat.id!);
                            if (staticMap['id'] == cat.id) {
                              final iconData = staticMap['icon'] as IconData;
                              if (cat.icon ==
                                  String.fromCharCode(iconData.codePoint)) {
                                iconWidget =
                                    Icon(iconData, color: catColor, size: 24);
                              }
                            }
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: iconWidget),
                              ),
                              title: Text(
                                cat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              subtitle: t.note != null && t.note!.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        t.note!,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : null,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCompact(t.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isIncome
                                          ? const Color(0xFF00E676)
                                          : const Color(0xFFFF5252),
                                    ),
                                  ),
                                  if (t.tags != null && t.tags!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          t.tags!.first,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );

    if (isTablet) {
      return TransactionPageIpad(child: body);
    }
    return TransactionPageMobile(child: body);
  }
}
