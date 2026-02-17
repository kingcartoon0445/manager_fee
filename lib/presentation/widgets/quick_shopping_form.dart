import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../injection_container.dart' as di;
import '../../domain/entities/category.dart' as entity;
import '../../domain/entities/budget.dart';
import '../blocs/budget/budget_bloc.dart';
import '../blocs/budget/budget_state.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../../core/thousand_separator_formatter.dart';
import '../../core/app_colors.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../blocs/budget/budget_event.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/quick_shopping_item_model.dart';
import '../blocs/quick_shopping/quick_shopping_cubit.dart';
import 'quick_shopping_edit_modal.dart';

class QuickShoppingForm extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool isEmbedded;

  const QuickShoppingForm({
    super.key,
    this.onSuccess,
    this.onCancel,
    this.isEmbedded = false,
  });

  @override
  State<QuickShoppingForm> createState() => _QuickShoppingFormState();
}

class _QuickShoppingFormState extends State<QuickShoppingForm> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<QuickShoppingCubit>()..loadItems(),
      child: Builder(builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Light Green
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shopping_basket,
                          color: Color(0xFF2E7D32), size: 18),
                      SizedBox(width: 8),
                      Text('Đi Chợ Nhanh',
                          style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _openEditModal(context),
                    ),
                    if (widget.onCancel != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: widget.onCancel,
                      ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            // Added expanded to scroll grid
            Expanded(
              flex: widget.isEmbedded ? 1 : 0,
              child: BlocBuilder<QuickShoppingCubit, QuickShoppingState>(
                builder: (context, state) {
                  if (state is QuickShoppingLoaded) {
                    return GridView.builder(
                      shrinkWrap: !widget.isEmbedded,
                      physics: widget.isEmbedded
                          ? const AlwaysScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.6, // Wider cards
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _buildCategoryCard(context, item);
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  void _openEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (context) => di.sl<QuickShoppingCubit>(),
        child: const QuickShoppingEditModal(),
      ),
    ).then((_) {
      // Reload items when returning from edit
      if (mounted) {
        // We need to trigger a reload in the Cubit that is provided ABOVE within this build method
        // But since we are inside a new context (modal), we need access to the parent cubit?
        // Actually, the BlocProvider is inside the build method.
        // So we can just call loadItems() on the cubit using the context from the Builder
        // BUT wait, _openEditModal uses context passed to it.
        // If we want to reload the LIST, we need to access the Cubit instance.
        // But the Cubit is created inside BlocProvider in build().
        // We can't access it easily here unless we pass it or use a key/global.
        //
        // SIMPLER FIX: Just trigger a rebuild which will create new provider? No that resets state.
        // Better: Expect the User to pull to refresh?
        // Or: The QuickShoppingEditModal updates the same data source.
        //
        // Let's rely on the fact that next time this widget builds (if it rebuilds) it loads.
        // For now, let's keep it simple. If live update is needed, we should lift the Cubit up.
        // Actually, for iPad, the form stays open.
        // Let's try to get the cubit from context.
        try {
          context.read<QuickShoppingCubit>().loadItems();
        } catch (_) {}
      }
    });
  }

  Widget _buildCategoryCard(BuildContext context, QuickShoppingItemModel item) {
    return InkWell(
      onTap: () => _showAmountDialog(context, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                IconData(item.iconCodePoint,
                    fontFamily: item.iconFontFamily,
                    fontPackage: item.iconFontPackage),
                color: Color(item.colorValue),
                size: 32),
            const SizedBox(height: 8),
            Text(item.label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(item.colorValue),
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showAmountDialog(
      BuildContext parentContext, QuickShoppingItemModel item) {
    showDialog(
      context: parentContext,
      builder: (context) => _QuickAmountDialog(
        item: item,
        onSave: (amount, note) {
          Navigator.pop(context); // Close dialog
          _saveTransaction(parentContext, item, amount, note);
        },
      ),
    );
  }

  Future<void> _saveTransaction(BuildContext context,
      QuickShoppingItemModel item, double amount, String? customNote) async {
    // 1. Get Configured Budget
    final prefs = di.sl<SharedPreferences>();
    await prefs.reload(); // Ensure latest config
    final budgetId = prefs.getInt('quick_shopping_budget_id');

    // Warning Checks
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

    if (budgetId != null) {
      final budgetState = context.read<BudgetBloc>().state;
      if (budgetState is BudgetLoaded) {
        try {
          // Find the budget.
          final budget =
              budgetState.budgets.firstWhere((b) => b.id == budgetId);
          // Calculate spent for this budget (Expense only)
          final spent = transactions
              .where((t) => t.budgetId == budgetId && t.type == 1)
              .fold(0.0, (sum, t) => sum + t.amount);

          if (spent + amount > budget.amount) {
            final newTotal = spent + amount;
            budgetToUpdate = budget;
            newBudgetAmount = newTotal;

            if (currentBalance < amount) {
              warningMessage = 'CẢNH BÁO KÉP (Đi chợ)!\n\n'
                  '1. Khoản chi này vượt quá hạn mức đi chợ.\n'
                  '2. Tiền tổng hiện có (${CurrencyFormatter.formatCompact(currentBalance)}) KHÔNG ĐỦ để chi trả!\n\n'
                  'Nếu đồng ý, hệ thống sẽ vẫn nâng hạn mức và ghi nhận khoản chi (tài khoản sẽ bị âm).';
            } else {
              warningMessage =
                  'Bạn đang sử dụng lố khoản định mức (Đi chợ)!\n\n'
                  'Hạn mức hiện tại: ${CurrencyFormatter.formatCompact(budget.amount)}\n'
                  'Đã chi: ${CurrencyFormatter.formatCompact(spent)}\n'
                  'Sẽ chi: ${CurrencyFormatter.formatCompact(newTotal)}\n\n'
                  'Hệ thống sẽ tự động nâng hạn mức lên ${CurrencyFormatter.formatCompact(newTotal)} đễ hỗ trợ khoản chi này.';
            }
          }
        } catch (_) {
          // Budget not found (maybe deleted), check Balance instead?
          // Or just ignore budget check.
        }
      }
    } else {
      // Check Total Balance
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

    if (!context.mounted) return;

    int finalCategoryId = item.dbCategoryId; // Default
    List<String> tags = ['Vợ'];

    // Try to find "Chợ" category
    final txState = context.read<TransactionBloc>().state;
    if (txState is TransactionLoaded) {
      try {
        final marketCategory = txState.categories.firstWhere(
            (c) => c.name == 'Chợ',
            orElse: () => entity.Category(
                id: null,
                name: '',
                type: 1,
                icon: '',
                colorValue: null)); // Dummy
        if (marketCategory.id != null) {
          finalCategoryId = marketCategory.id!;
        }
      } catch (_) {}
    }

    if (budgetId != null) {
      final budgetState = context.read<BudgetBloc>().state;
      if (budgetState is BudgetLoaded) {
        try {
          final budget =
              budgetState.budgets.firstWhere((b) => b.id == budgetId);
          // if (budget.categoryId != null) { ... } // Ignored as per plan
          tags.add(
              'Chi từ quỹ: ${budget.name}'); // Optional: Add tag for clarity
        } catch (e) {
          // Budget might be deleted
        }
      }
    }

    final transaction = entity.Transaction(
      amount: amount,
      type: 1, // Expense
      categoryId: finalCategoryId,
      date: DateTime.now(),
      note: customNote ?? item.note,
      memberId: 'Vợ',
      tags: tags,
      budgetId: budgetId,
    );

    // Dispatch
    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  'Đã thêm: ${item.label} - ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(amount)}'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    }
  }
}

class _QuickAmountDialog extends StatefulWidget {
  final QuickShoppingItemModel item;
  final Function(double, String?) onSave;

  const _QuickAmountDialog({required this.item, required this.onSave});

  @override
  State<_QuickAmountDialog> createState() => _QuickAmountDialogState();
}

class _QuickAmountDialogState extends State<_QuickAmountDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();
  bool _isCustomNote = false;

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.item.note;

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _amountController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _amountController.text.length,
        );
      }
    });

    _noteFocusNode.addListener(() {
      if (_noteFocusNode.hasFocus) {
        _noteController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _noteController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(widget.item.colorValue).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            IconData(widget.item.iconCodePoint,
                                fontFamily: widget.item.iconFontFamily,
                                fontPackage: widget.item.iconFontPackage),
                            color: Color(widget.item.colorValue),
                            size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.item.label,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text('Nhập số tiền', style: TextStyle(color: Colors.grey)),
              TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32)),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2E7D32), width: 2)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2E7D32), width: 2)),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              // Custom Note Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sửa ghi chú',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                value: _isCustomNote,
                onChanged: (val) {
                  setState(() {
                    _isCustomNote = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: AppColors.primaryBlue,
              ),
              // Custom Note Field
              if (_isCustomNote)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _noteController,
                    focusNode: _noteFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Nhập ghi chú...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _amountController,
                builder: (context, value, child) {
                  final hasValue = value.text.isNotEmpty &&
                      (ThousandsSeparatorInputFormatter.parseFormattedNumber(
                                  value.text) ??
                              0) >
                          0;

                  return ElevatedButton(
                    onPressed: hasValue
                        ? () {
                            final val = ThousandsSeparatorInputFormatter
                                .parseFormattedNumber(_amountController.text);
                            if (val != null && val > 0) {
                              final note = _isCustomNote
                                  ? _noteController.text
                                  : widget.item.note;
                              widget.onSave(val, note);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: hasValue
                            ? AppColors.buttonEnabledSuccess
                            : AppColors.buttonDisabledLight,
                        foregroundColor: AppColors.buttonTextEnabled,
                        disabledBackgroundColor: AppColors.buttonDisabledLight,
                        disabledForegroundColor: AppColors.buttonTextDisabled,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0),
                    child: Text('Lưu Ngay',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: hasValue
                                ? AppColors.buttonTextEnabled
                                : AppColors.buttonTextDisabled)),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
