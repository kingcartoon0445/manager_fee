import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/budget/budget_bloc.dart';
import '../blocs/budget/budget_event.dart';
import '../blocs/budget/budget_state.dart';
import '../../core/thousand_separator_formatter.dart';
import '../../core/app_colors.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../injection_container.dart' as di;
import '../../core/utils/currency_formatter.dart';
import '../../domain/usecases/predict_category_usecase.dart';
import 'dart:async';

class AddTransactionModal extends StatefulWidget {
  final double? initialAmount;
  final String? initialNote;
  final DateTime? initialDate;

  const AddTransactionModal({
    super.key,
    this.initialAmount,
    this.initialNote,
    this.initialDate,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int _selectedType = 1; // 1: Expense (Default), 0: Income
  int _selectedCategoryId = 1;
  DateTime _selectedDate = DateTime.now();
  int? _selectedBudgetId;
  final String _selectedMember = 'Chồng';
  List<Category> _allCategories = [];
  bool _isLoadingCategories = true;
  Timer? _debounce;

  // Get categories based on selected type
  List<Category> get _categories =>
      _allCategories.where((c) => c.type == _selectedType).toList();

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text =
          NumberFormat.decimalPattern('vi').format(widget.initialAmount);
    }
    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    _loadCategories();
    _noteController.addListener(_onNoteChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final note = _noteController.text;
      if (note.length > 2) {
        try {
          final predictUseCase = di.sl<PredictCategoryUseCase>();
          final predictedCatId = await predictUseCase(note, _selectedType);
          if (predictedCatId != null && mounted) {
            // Verify if the category exists in current type list
            final exists = _categories.any((c) => c.id == predictedCatId);
            if (exists) {
              setState(() {
                _selectedCategoryId = predictedCatId;
              });
              // Optional: Show feedback? Maybe too intrusive.
              // Just auto-selection is fine.
            }
          }
        } catch (e) {
          print('Prediction error: $e');
        }
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();
      final categories = await getCategoriesUseCase();
      setState(() {
        _allCategories = categories;
        _isLoadingCategories = false;
        // Set default category based on type
        final typedCategories = _categories;
        if (typedCategories.isNotEmpty) {
          _selectedCategoryId = typedCategories.first.id ?? 1;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make bottom sheet height dynamic but capped
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thêm Giao Dịch Mới',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Tabs (Income/Expense)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTab('Chi tiêu', 1)),
                      Expanded(child: _buildTab('Thu nhập', 0)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Amount Input
                        const Text('Số tiền (VND)',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2962FF)),
                          decoration: const InputDecoration(
                              hintText: '0',
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF2962FF), width: 2)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF2962FF), width: 2)),
                              suffixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_drop_up),
                                  Icon(Icons.arrow_drop_down)
                                ], // Mockup arrows
                              )),
                        ),
                        const SizedBox(height: 20),

                        // Budget Selector (Only for Expense)
                        if (_selectedType == 1) ...[
                          const Text('Trừ vào hạn mức (Tùy chọn)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey)),
                          const SizedBox(height: 8),
                          BlocBuilder<BudgetBloc, BudgetState>(
                            builder: (context, state) {
                              String currentName =
                                  '-- Không áp dụng hạn mức --';
                              if (state is BudgetLoaded &&
                                  _selectedBudgetId != null) {
                                try {
                                  final b = state.budgets.firstWhere(
                                      (e) => e.id == _selectedBudgetId);
                                  currentName =
                                      '${b.name} (${CurrencyFormatter.formatCompact(b.amount)})';
                                } catch (_) {}
                              }

                              // Looking at file content, 'import '../../domain/entities/budget.dart';' is NOT explicitly imported in header viewed earlier?
                              // Let's check imports again.
                              // Actually usage 'state.budgets' implies it knows the type.
                              // In _showBudgetPicker signature I need 'Budget' type.
                              // I should check if Budget is imported.

                              return InkWell(
                                onTap: () => state is BudgetLoaded
                                    ? _showBudgetPicker(context, state.budgets)
                                    : null,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    suffixIcon:
                                        const Icon(Icons.arrow_drop_down),
                                  ),
                                  child: Text(
                                    currentName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Note
                        const Text('Ghi chú',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 3,
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'Ví dụ: Mua rau, đổ xăng...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ngày',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(DateFormat('dd/MM/yyyy')
                                              .format(_selectedDate)),
                                          const Icon(Icons.calendar_today,
                                              size: 16, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),

                        // Category Grid
                        const Text('Danh mục',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        const SizedBox(height: 12),
                        _isLoadingCategories
                            ? const Center(child: CircularProgressIndicator())
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.85,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final cat = _categories[index];
                                  final isSelected =
                                      _selectedCategoryId == cat.id;
                                  final color = cat.colorValue != null
                                      ? Color(cat.colorValue!)
                                      : Colors.grey;

                                  return GestureDetector(
                                    onTap: () => setState(() =>
                                        _selectedCategoryId = cat.id ?? 1),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? color.withOpacity(0.15)
                                                : Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: isSelected
                                                ? Border.all(
                                                    color: color, width: 2.5)
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              cat.icon ?? '📁',
                                              style:
                                                  const TextStyle(fontSize: 28),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? color
                                                : Colors.grey[700],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        // const SizedBox(height: 12),

                        // Date & Member
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Submit Button
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _amountController,
                  builder: (context, value, child) {
                    final hasValue = value.text.isNotEmpty &&
                        (ThousandsSeparatorInputFormatter.parseFormattedNumber(
                                    value.text) ??
                                0) >
                            0;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: hasValue ? _saveTransaction : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasValue
                              ? AppColors.buttonEnabled
                              : AppColors.buttonDisabledLight,
                          foregroundColor: AppColors.buttonTextEnabled,
                          disabledBackgroundColor:
                              AppColors.buttonDisabledLight,
                          disabledForegroundColor: AppColors.buttonTextDisabled,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check,
                                color: hasValue
                                    ? AppColors.buttonTextEnabled
                                    : AppColors.buttonTextDisabled),
                            const SizedBox(width: 8),
                            Text('Lưu Giao Dịch',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: hasValue
                                        ? AppColors.buttonTextEnabled
                                        : AppColors.buttonTextDisabled)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ]),
        ));
  }

  Widget _buildTab(String label, int type) {
    final isSelected = _selectedType == type;
    // Chi tiêu (type 1) = Red, Thu nhập (type 0) = Green
    final selectedColor =
        type == 1 ? AppColors.errorRed : AppColors.successGreen;
    final unselectedColor = Colors.grey[700]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // Reset category to first of new type
          final typedCategories = _categories;
          if (typedCategories.isNotEmpty) {
            _selectedCategoryId = typedCategories.first.id ?? 1;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 1
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: isSelected ? Colors.white : unselectedColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime tempDate = _selectedDate;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text('Hủy', style: TextStyle(color: Colors.grey)),
                  ),
                  const Text('Chọn ngày',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedDate = tempDate);
                      Navigator.pop(context);
                    },
                    child: Text('Xong',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now().add(const Duration(seconds: 1)),
                  minimumYear: 2000,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (val) {
                    tempDate = val;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    final amount = ThousandsSeparatorInputFormatter.parseFormattedNumber(
        _amountController.text);
    if (amount == null || amount <= 0) return;

    // Check for warnings
    if (_selectedType == 1) {
      // Only for Expense
      final repo = di.sl<TransactionRepository>();
      final transactions = await repo.getTransactions();
      String? warningMessage;
      Budget? budgetToUpdate;
      double? newBudgetAmount;

      final totalIncome = transactions
          .where((t) => t.type == 0)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == 1)
          .fold(0.0, (sum, t) => sum + t.amount);
      final currentBalance = totalIncome - totalExpense;

      if (_selectedBudgetId != null) {
        // Check Budget Limit
        final budgetState = context.read<BudgetBloc>().state;
        if (budgetState is BudgetLoaded) {
          try {
            final budget = budgetState.budgets
                .firstWhere((b) => b.id == _selectedBudgetId);
            final spent = transactions
                .where((t) => t.budgetId == _selectedBudgetId && t.type == 1)
                .fold(0.0, (sum, t) => sum + t.amount);

            if (spent + amount > budget.amount) {
              final newTotal = spent + amount;
              budgetToUpdate = budget;
              newBudgetAmount = newTotal;

              if (currentBalance < amount) {
                // Logic: Does the WALLET (Total Balance) have enough money to pay for THIS transaction?
                // If CurrentBalance < Amount, then we are entering Negative Balance regardless of budget.
                warningMessage = 'CẢNH BÁO KÉP!\n\n'
                    '1. Khoản chi này vượt quá hạn mức ví (${CurrencyFormatter.formatCompact(budget.amount)}).\n'
                    '2. Tiền tổng hiện có (${CurrencyFormatter.formatCompact(currentBalance)}) KHÔNG ĐỦ để chi trả khoản này!\n\n'
                    'Nếu đồng ý, hệ thống sẽ vẫn nâng hạn mức và ghi nhận khoản chi (tài khoản sẽ bị âm).';
              } else {
                warningMessage = 'Bạn đang sử dụng lố khoản định mức!\n\n'
                    'Hạn mức hiện tại: ${CurrencyFormatter.formatCompact(budget.amount)}\n'
                    'Đã chi: ${CurrencyFormatter.formatCompact(spent)}\n'
                    'Sẽ chi: ${CurrencyFormatter.formatCompact(newTotal)}\n\n'
                    'Hệ thống sẽ tự động nâng hạn mức lên ${CurrencyFormatter.formatCompact(newTotal)} đễ hỗ trợ khoản chi này.';
              }
            }
          } catch (_) {}
        }
      } else {
        // Check Total Balance (No Budget)
        if (currentBalance - amount < 0) {
          warningMessage = 'Bạn đang sử dụng hết tiền dư!\n\n'
              'Số dư hiện tại: ${CurrencyFormatter.formatCompact(currentBalance)}\n'
              'Sau khi chi: ${CurrencyFormatter.formatCompact(currentBalance - amount)}';
        }
      }

      if (warningMessage != null) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cảnh báo chi tiêu',
                style: TextStyle(color: Colors.red)),
            content: Text(warningMessage!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Continue
                child: const Text('Đồng ý',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        // Apply automatic budget increase if needed
        if (budgetToUpdate != null && newBudgetAmount != null) {
          context.read<BudgetBloc>().add(UpdateBudgetEvent(
              budgetToUpdate.copyWith(amount: newBudgetAmount)));
        }
      }
    }

    if (!mounted) return;

    List<String> tags = [];
    if (_selectedMember.isNotEmpty) tags.add(_selectedMember);
    if (_selectedBudgetId != null && _selectedType == 1) tags.add('CÓ HẠN MỨC');

    final transaction = entity.Transaction(
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      note: _noteController.text,
      tags: tags,
      budgetId: _selectedType == 1 ? _selectedBudgetId : null,
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    Navigator.pop(context);
  }

  void _showBudgetPicker(BuildContext context, List<Budget> budgets) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn hạn mức chi tiêu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: budgets.length + 1, // +1 for Default
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = _selectedBudgetId == null;
                      return ListTile(
                        leading: const Icon(Icons.account_balance_wallet,
                            color: Colors.grey),
                        title: const Text('-- Không áp dụng hạn mức --',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                        trailing: isSelected
                            ? Icon(Icons.check,
                                color: Theme.of(context).primaryColor)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedBudgetId = null;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }

                    final budget =
                        budgets[index - 1]; // This is 'Budget' entity
                    final isSelected = budget.id == _selectedBudgetId;
                    return ListTile(
                      leading:
                          const Icon(Icons.track_changes, color: Colors.blue),
                      title: Text(budget.name ?? ''),
                      subtitle: Text(
                          CurrencyFormatter.formatCompact(budget.amount ?? 0)),
                      trailing: isSelected
                          ? Icon(Icons.check,
                              color: Theme.of(context).primaryColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedBudgetId = budget.id;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
