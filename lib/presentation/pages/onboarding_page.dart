import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/onboarding/onboarding_bloc.dart';
import '../blocs/onboarding/onboarding_event.dart';
import '../blocs/onboarding/onboarding_state.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../injection_container.dart' as di;
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/entities/category.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 2: Initial balance
  final TextEditingController _balanceController = TextEditingController();
  double _initialBalance = 0;

  // Step 3: Recurring transactions
  final List<_RecurringTransactionItem> _recurringItems = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();
    final categories = await getCategoriesUseCase();
    setState(() {
      // Filter out the "Initial Balance" category (id = 1)
      _categories = categories.where((c) => c.id != 1).toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    final recurringTransactions = _recurringItems.map((item) {
      return RecurringTransaction(
        amount: item.amount,
        type: item.type,
        categoryId: item.categoryId,
        dayOfMonth: item.dayOfMonth,
        note: item.note.isEmpty ? null : item.note,
      );
    }).toList();

    context.read<OnboardingBloc>().add(CompleteOnboarding(
          initialBalance: _initialBalance,
          recurringTransactions: recurringTransactions,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: index == 2 ? 0 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildWelcomeStep(),
                      _buildInitialBalanceStep(),
                      _buildRecurringTransactionsStep(),
                    ],
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _previousPage,
                          child: const Text('Quay lại'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == 0) {
                            _nextPage();
                          } else if (_currentPage == 1) {
                            // Parse and save balance
                            final text = _balanceController.text
                                .replaceAll(',', '')
                                .replaceAll('.', '');
                            _initialBalance = double.tryParse(text) ?? 0;
                            _nextPage();
                          } else {
                            _completeOnboarding();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _currentPage == 2 ? 'Hoàn thành' : 'Tiếp tục',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/peab.svg',
            width: 150,
            height: 150,
          ),
          // const Icon(
          //   Icons.account_balance_wallet,
          //   size: 100,
          //   color: Colors.blue,
          // ),
          const SizedBox(height: 32),
          const Text(
            'Chào mừng đến với Pead Get',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Hãy thiết lập thông tin ban đầu để bắt đầu quản lý tài chính của bạn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem('💰', 'Thay đổi số dư hiện tại'),
                const SizedBox(height: 12),
                _buildFeatureItem('📅', 'Thiết lập thu chi hằng tháng'),
                const SizedBox(height: 12),
                _buildFeatureItem('📊', 'Theo dõi chi tiêu tự động'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInitialBalanceStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Thay đổi số dư hiện tại',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Nhập số tiền hiện tại của bạn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              // suffixText: 'VND',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn có thể nhập số âm nếu đang nợ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringTransactionsStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Thu chi hằng tháng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm các khoản thu/chi định kỳ hàng tháng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // List of recurring items
          Expanded(
            child: _recurringItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có giao dịch định kỳ nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bạn có thể bỏ qua bước này',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _recurringItems.length,
                    itemBuilder: (context, index) {
                      final item = _recurringItems[index];
                      final category = _categories.firstWhere(
                        (c) => c.id == item.categoryId,
                        orElse: () => Category(
                          id: 0,
                          name: 'Unknown',
                          type: 0,
                          icon: '❓',
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Text(
                            category.icon ?? '📝',
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(category.name),
                          subtitle: Text(
                            'Ngày ${item.dayOfMonth} hàng tháng',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: '',
                                  decimalDigits: 0,
                                ).format(item.amount),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: item.type == 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _recurringItems.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Add button
          OutlinedButton.icon(
            onPressed: () => _showAddRecurringDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm giao dịch định kỳ'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecurringDialog() {
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    int? selectedCategoryId;
    int selectedDay = 1;
    int selectedType = 1; // 1: Expense (default), 0: Income

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Thêm khoản cố định mới',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toggle Type (Chi tiêu / Thu nhập)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogTypeButton(
                            'Chi tiêu',
                            1,
                            selectedType,
                            (type) {
                              setDialogState(() {
                                selectedType = type;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogTypeButton(
                            'Thu nhập',
                            0,
                            selectedType,
                            (type) {
                              setDialogState(() {
                                selectedType = type;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Note/Name field
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Tên (VD: Tiền nhà)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Số tiền',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsSeparatorInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category selector
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        hintText: 'Chọn danh mục',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Text(
                                category.icon ?? '📝',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Day of month
                    DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: InputDecoration(
                        hintText: 'Ngày trong tháng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: List.generate(31, (index) => index + 1)
                          .map((day) => DropdownMenuItem(
                                value: day,
                                child: Text('Ngày $day'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDay = value ?? 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng chọn danh mục'),
                        ),
                      );
                      return;
                    }

                    final amountText = amountController.text
                        .replaceAll(',', '')
                        .replaceAll('.', '');
                    final amount = double.tryParse(amountText) ?? 0;

                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập số tiền hợp lệ'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _recurringItems.add(_RecurringTransactionItem(
                        amount: amount,
                        type:
                            selectedType, // Use selected type instead of category type
                        categoryId: selectedCategoryId!,
                        dayOfMonth: selectedDay,
                        note: noteController.text,
                      ));
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTypeButton(
      String label, int type, int selectedType, Function(int) onTap) {
    final isSelected = selectedType == type;
    // Chi tiêu (type 1) = Red, Thu nhập (type 0) = Green
    final selectedColor = type == 1 ? Colors.red : Colors.green;
    final unselectedColor = Colors.grey[300]!;

    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 1
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringTransactionItem {
  final double amount;
  final int type;
  final int categoryId;
  final int dayOfMonth;
  final String note;

  _RecurringTransactionItem({
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.dayOfMonth,
    required this.note,
  });
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = NumberFormat('#,###', 'en_US').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
