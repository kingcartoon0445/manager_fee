import 'package:package_info_plus/package_info_plus.dart';
import 'package:peadget/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../injection_container.dart' as di;
import '../../../domain/usecases/clear_data_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/recurring_transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../blocs/budget/budget_event.dart';
import '../../blocs/budget/budget_state.dart';
import '../../blocs/recurring_transaction/recurring_transaction_bloc.dart';
import '../../blocs/recurring_transaction/recurring_transaction_event.dart';
import '../../blocs/recurring_transaction/recurring_transaction_state.dart';

import '../../../core/thousand_separator_formatter.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive_layout.dart';
import '../../../core/category_icons.dart';
import '../../../data/services/data_export_service.dart';
import '../../../data/services/data_import_service.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/datasources/isar_service.dart';
import 'mobile/settings_page_mobile.dart';
import 'ipad/settings_page_ipad.dart';
import 'api_key_instruction_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Version Info
  String _version = '';

  // Input Controllers for Budget
  final _budgetNameController = TextEditingController();
  final _budgetAmountController = TextEditingController();

  final _initialBalanceController = TextEditingController();
  final _geminiApiKeyController = TextEditingController();
  List<Map<String, String>> _availableModels = [];
  String? _selectedModelId;
  bool _isLoadingModels = false;

  // Input Controllers for Recurring
  final _recurringNameController = TextEditingController();
  final _recurringAmountController = TextEditingController();
  int _recurringType = 1; // 1: Expense (default), 0: Income
  int _recurringDayOfMonth = 1; // Day of month (1-31)
  int? _selectedCategoryId; // Selected category for recurring transaction
  List<Category> _categories = []; // Categories loaded from DB

  // Quick Shopping Config
  int? _quickShoppingBudgetId; // Null means "Default" (Automatic)

  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadBudgets());
    context.read<RecurringTransactionBloc>().add(LoadRecurringTransactions());
    _loadQuickShoppingConfig();
    _loadInitialBalance();
    _loadApiKey();
    _loadCategories();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _loadApiKey() async {
    final appSettingsRepo = di.sl<AppSettingsRepository>();
    final settings = await appSettingsRepo.getAppSettings();
    if (settings?.geminiApiKey != null) {
      _geminiApiKeyController.text = settings!.geminiApiKey!;
      _selectedModelId = settings.geminiModelId ?? 'gemini-1.5-flash';
      // Auto fetch models if key exists
      _fetchModels(settings.geminiApiKey!);
    }
  }

  Future<void> _fetchModels(String apiKey) async {
    if (apiKey.isEmpty) return;

    setState(() {
      _isLoadingModels = true;
    });

    try {
      final models = await AiService.getAvailableModels(apiKey);
      setState(() {
        _availableModels = models;
        // If selected model is not in list, default to first or keep it?
        // Keep it if possible, otherwise mapped.
        if (_availableModels.isNotEmpty &&
            !_availableModels.any((m) => m['id'] == _selectedModelId)) {
          _selectedModelId = _availableModels.first['id'];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách models: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingModels = false;
        });
      }
    }
  }

  Future<void> _saveApiKey() async {
    final appSettingsRepo = di.sl<AppSettingsRepository>();
    final settings = await appSettingsRepo.getAppSettings();
    if (settings != null) {
      // Create new object with updated key (since entity is immutable usually, or we assume copyWith-like)
      // AppSettings entity doesn't have copyWith. We need to reconstruct.
      // Wait, AppSettingsRepositoryImpl.saveAppSettings writes ALL fields from input object.
      // So we must ensure we have all current fields.

      final newSettings = AppSettings(
        id: settings.id,
        hasCompletedOnboarding: settings.hasCompletedOnboarding,
        onboardingCompletedAt: settings.onboardingCompletedAt,
        initialBalance: settings.initialBalance,
        lastClosedMonth: settings.lastClosedMonth,
        geminiApiKey: _geminiApiKeyController.text.trim(),
        geminiModelId: _selectedModelId,
      );

      await appSettingsRepo.saveAppSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu API Key')),
        );
        FocusScope.of(context).unfocus();
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();
      final categories = await getCategoriesUseCase();
      setState(() {
        // Filter out the special "Initial Balance" category (id = 1)
        _categories = categories.where((c) => c.id != 1).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadInitialBalance() async {
    final prefs = di.sl<SharedPreferences>();
    final amount = prefs.getDouble('initial_balance');
    if (amount != null) {
      _initialBalanceController.text =
          amount.toStringAsFixed(0); // Show as integer
    }
  }

  Future<void> _saveInitialBalance() async {
    final prefs = di.sl<SharedPreferences>();
    final amount = ThousandsSeparatorInputFormatter.parseFormattedNumber(
        _initialBalanceController.text);
    if (amount != null) {
      await prefs.setDouble('initial_balance', amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu số dư khởi tạo')),
        );
      }
    }
  }

  Future<void> _loadQuickShoppingConfig() async {
    final prefs = di.sl<SharedPreferences>();
    setState(() {
      _quickShoppingBudgetId = prefs.getInt('quick_shopping_budget_id');
      // If it returns null, it remains null (Default)
    });
  }

  Future<void> _saveQuickShoppingConfig(int? budgetId) async {
    final prefs = di.sl<SharedPreferences>();
    if (budgetId == null) {
      await prefs.remove('quick_shopping_budget_id');
    } else {
      await prefs.setInt('quick_shopping_budget_id', budgetId);
    }
    setState(() {
      _quickShoppingBudgetId = budgetId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            title: const Text('Cài Đặt',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    fontSize: 24)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          body: _buildBody(context),
        ));
  }

  Widget _buildBody(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCard(
            title: 'Số Dư Khởi Tạo',
            icon: null,
            children: [
              const Text(
                'Số tiền này dùng để tính toán số dư đầu kỳ cho tháng đầu tiên sử dụng app.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _initialBalanceController,
                      decoration: InputDecoration(
                        prefixText: '₫ ',
                        hintText: '5000000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _initialBalanceController,
                    builder: (context, value, child) {
                      final hasValue = value.text.isNotEmpty &&
                          (ThousandsSeparatorInputFormatter
                                      .parseFormattedNumber(value.text) ??
                                  0) >
                              0;

                      return ElevatedButton(
                        onPressed: hasValue ? _saveInitialBalance : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasValue
                              ? AppColors.buttonEnabled
                              : AppColors.buttonDisabledLight,
                          foregroundColor: AppColors.buttonTextEnabled,
                          disabledBackgroundColor:
                              AppColors.buttonDisabledLight,
                          disabledForegroundColor: AppColors.buttonTextDisabled,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Lưu'),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // AI Configuration Section
          _buildCard(
            title: 'Cấu Hình Trợ Lý AI',
            icon: Icons.smart_toy,
            iconColor: Colors.deepPurple,
            children: [
              const Text(
                'Nhập Gemini API Key để sử dụng các tính năng thông minh (Nhập liệu tự nhiên, Quét hóa đơn).',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _geminiApiKeyController,
                decoration: InputDecoration(
                  hintText: 'Nhập API Key...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save, color: Colors.blue),
                    onPressed: _saveApiKey,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              if (_geminiApiKeyController.text.isNotEmpty)
                const SizedBox.shrink(),
              // Row(
              //   children: [
              //     Expanded(
              //       child: _isLoadingModels
              //           ? const Center(
              //               child: SizedBox(
              //                   height: 20,
              //                   width: 20,
              //                   child: CircularProgressIndicator(
              //                       strokeWidth: 2)))
              //           : DropdownButtonFormField<String>(
              //               value: _selectedModelId,
              //               decoration: InputDecoration(
              //                 labelText: 'Chọn Model AI',
              //                 border: OutlineInputBorder(
              //                   borderRadius: BorderRadius.circular(12),
              //                 ),
              //                 contentPadding:
              //                     const EdgeInsets.symmetric(
              //                         horizontal: 12, vertical: 12),
              //               ),
              //               items: _availableModels.map((m) {
              //                 return DropdownMenuItem(
              //                   value: m['id'],
              //                   child: Text(
              //                     m['name'] ?? m['id']!,
              //                     overflow: TextOverflow.ellipsis,
              //                     style: const TextStyle(fontSize: 13),
              //                   ),
              //                 );
              //               }).toList(),
              //               onChanged: _availableModels.isEmpty
              //                   ? null
              //                   : (val) {
              //                       setState(() {
              //                         _selectedModelId = val;
              //                       });
              //                     },
              //             ),
              //     ),
              //     const SizedBox(width: 8),
              //     IconButton(
              //       icon: const Icon(Icons.refresh),
              //       tooltip: 'Tải lại danh sách Model',
              //       onPressed: () => _fetchModels(
              //           _geminiApiKeyController.text.trim()),
              //     )
              //   ],
              // ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ApiKeyInstructionPage()),
                  );
                },
                child: const Text(
                  'Chưa có key? Xem hướng dẫn lấy tại đây',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Theme Color Section
          // _buildCard(
          //   title: 'Màu Chủ Đạo',
          //   icon: Icons.palette,
          //   iconColor: Colors.purple,
          //   children: [
          //     const Text(
          //       'Tùy chỉnh màu sắc giao diện ứng dụng theo sở thích của bạn.',
          //       style: TextStyle(color: Colors.grey, fontSize: 13),
          //     ),
          //     const SizedBox(height: 16),
          //     BlocBuilder<ThemeCubit, ThemeState>(
          //       builder: (context, themeState) {
          //         return InkWell(
          //           onTap: () {
          //             showDialog(
          //               context: context,
          //               builder: (_) => BlocProvider.value(
          //                 value: context.read<ThemeCubit>(),
          //                 child: const ThemePickerDialog(),
          //               ),
          //             );
          //           },
          //           child: Container(
          //             padding: const EdgeInsets.all(16),
          //             decoration: BoxDecoration(
          //               color: const Color(0xFFF8F9FD),
          //               borderRadius: BorderRadius.circular(12),
          //               border: Border.all(
          //                 color: themeState.primaryColor.withOpacity(0.3),
          //                 width: 2,
          //               ),
          //             ),
          //             child: Row(
          //               children: [
          //                 Container(
          //                   width: 48,
          //                   height: 48,
          //                   decoration: BoxDecoration(
          //                     color: themeState.primaryColor,
          //                     shape: BoxShape.circle,
          //                     boxShadow: [
          //                       BoxShadow(
          //                         color: themeState.primaryColor
          //                             .withOpacity(0.4),
          //                         blurRadius: 8,
          //                         offset: const Offset(0, 2),
          //                       ),
          //                     ],
          //                   ),
          //                   child: const Icon(
          //                     Icons.palette,
          //                     color: Colors.white,
          //                     size: 24,
          //                   ),
          //                 ),
          //                 const SizedBox(width: 16),
          //                 Expanded(
          //                   child: Column(
          //                     crossAxisAlignment:
          //                         CrossAxisAlignment.start,
          //                     children: [
          //                       const Text(
          //                         'Màu hiện tại',
          //                         style: TextStyle(
          //                           color: Colors.grey,
          //                           fontSize: 12,
          //                         ),
          //                       ),
          //                       const SizedBox(height: 4),
          //                       Text(
          //                         '#${themeState.primaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
          //                         style: const TextStyle(
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 16,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //                 Icon(
          //                   Icons.arrow_forward_ios,
          //                   size: 16,
          //                   color: Colors.grey[400],
          //                 ),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 20),

          // Quick Shopping Config Section
          _buildCard(
            title: 'Cấu Hình Đi Chợ Nhanh',
            icon: Icons.shopping_basket,
            iconColor: Colors.green,
            children: [
              const Text(
                'Chọn hạn mức (ví) để trừ tiền khi sử dụng tính năng "Đi Chợ Nhanh".',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is BudgetLoaded) {
                    // Find current selected name
                    String currentName = 'Mặc định (Trừ vào tiền tổng)';
                    final selectedExists = _quickShoppingBudgetId != null;
                    if (selectedExists) {
                      final b = state.budgets.firstWhere(
                          (element) => element.id == _quickShoppingBudgetId,
                          orElse: () => state.budgets.first); // fallback
                      // Re-verify if it matches ID actually (firstWhere throws or returns default? returns first match. We checked selectedExists)
                      // Actually safer to just iterate or use firstWhereOrNull logic
                      try {
                        final b = state.budgets
                            .firstWhere((e) => e.id == _quickShoppingBudgetId);
                        currentName =
                            '${b.name} (${CurrencyFormatter.formatCompact(b.amount)})';
                      } catch (_) {}
                    }

                    return InkWell(
                      onTap: () => _showBudgetPicker(context, state.budgets),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          currentName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return const SizedBox
                      .shrink(); // Loading state handled by parent or empty
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Budget Section
          _buildCard(
            title: 'Hạn Mức Chi Tiêu (Ví Ngân Sách)',
            icon: Icons.track_changes,
            iconColor: Colors.deepOrange,
            children: [
              const Text(
                'Tạo các hạn mức để kiểm soát chi tiêu (Ví dụ: Tiền ăn, Tiền xăng).',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // List of Budgets
              BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is BudgetLoaded) {
                    return Column(
                      children: state.budgets
                          .map((budget) => _buildBudgetRow(context, budget))
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Divider(height: 32),

              // Add Budget Form
              const Text('Thêm hạn mức mới',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetNameController,
                decoration: InputDecoration(
                  hintText: 'Tên hạn mức (VD: Tiền ăn)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'Số tiền hạn mức',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _budgetNameController,
                builder: (context, nameValue, child) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _budgetAmountController,
                    builder: (context, amountValue, child) {
                      final hasName = nameValue.text.trim().isNotEmpty;
                      final hasAmount = amountValue.text.isNotEmpty &&
                          (ThousandsSeparatorInputFormatter
                                      .parseFormattedNumber(amountValue.text) ??
                                  0) >
                              0;
                      final isValid = hasName && hasAmount;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isValid ? _addBudget : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? AppColors.buttonEnabled
                                : AppColors.buttonDisabledLight,
                            foregroundColor: AppColors.buttonTextEnabled,
                            disabledBackgroundColor:
                                AppColors.buttonDisabledLight,
                            disabledForegroundColor:
                                AppColors.buttonTextDisabled,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Tạo Hạn Mức',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isValid
                                      ? AppColors.buttonTextEnabled
                                      : AppColors.buttonTextDisabled)),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Recurring Transactions Section
          _buildCard(
            title: 'Thu Chi Cố Định Hàng Tháng',
            icon: Icons.calendar_today,
            iconColor: Colors.blue,
            children: [
              const Text(
                'Các khoản này sẽ tự động được thêm vào giao dịch vào ngày đã chọn hàng tháng.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // List
              BlocBuilder<RecurringTransactionBloc, RecurringTransactionState>(
                builder: (context, state) {
                  if (state is RecurringTransactionLoaded) {
                    return Column(
                      children: state.transactions
                          .map((t) => _buildRecurringRow(context, t))
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Divider(height: 32),

              // Add Form
              const Text('Thêm khoản cố định mới',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),

              // Toggle Type
              Row(
                children: [
                  Expanded(child: _buildTypeButton('Chi tiêu', 1)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTypeButton('Thu nhập', 0)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _recurringNameController,
                decoration: InputDecoration(
                  hintText: 'Tên (VD: Tiền nhà)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _recurringAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'Số tiền',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showCategoryPicker(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Chọn danh mục',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  child: _selectedCategoryId != null
                      ? (() {
                          final category = _categories.firstWhere(
                              (c) => c.id == _selectedCategoryId,
                              orElse: () => const Category(
                                  id: -1,
                                  name: 'Danh mục khác',
                                  type: 1,
                                  icon: '?'));

                          final catColor = category.colorValue != null
                              ? Color(category.colorValue!)
                              : CategoryIcons.getColorByName(category.name);

                          Widget iconWidget = Text(
                            category.icon ?? '?',
                            style: const TextStyle(fontSize: 20),
                          );

                          if (category.id != null) {
                            final staticMap =
                                CategoryIcons.getCategoryById(category.id!);
                            if (staticMap['id'] == category.id) {
                              final iconData = staticMap['icon'] as IconData;
                              if (category.icon ==
                                  String.fromCharCode(iconData.codePoint)) {
                                iconWidget =
                                    Icon(iconData, color: catColor, size: 20);
                              }
                            }
                          }

                          return Row(
                            children: [
                              iconWidget,
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          );
                        })()
                      : const Text('Chọn danh mục',
                          style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 12),

              // Day of Month Selector (iOS-style)
              GestureDetector(
                onTap: () => _showDayPicker(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày phát sinh trong tháng',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ngày $_recurringDayOfMonth',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Giao dịch sẽ tự động được tạo vào ngày này hàng tháng',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _recurringNameController,
                builder: (context, nameValue, child) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _recurringAmountController,
                    builder: (context, amountValue, child) {
                      final hasName = nameValue.text.trim().isNotEmpty;
                      final hasAmount = amountValue.text.isNotEmpty &&
                          (ThousandsSeparatorInputFormatter
                                      .parseFormattedNumber(amountValue.text) ??
                                  0) >
                              0;
                      final isValid = hasName && hasAmount;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isValid ? _addRecurring : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? AppColors.buttonEnabled
                                : AppColors.buttonDisabledLight,
                            foregroundColor: AppColors.buttonTextEnabled,
                            disabledBackgroundColor:
                                AppColors.buttonDisabledLight,
                            disabledForegroundColor:
                                AppColors.buttonTextDisabled,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Thêm Cài Đặt',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isValid
                                      ? AppColors.buttonTextEnabled
                                      : AppColors.buttonTextDisabled)),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Data Backup & Restore
          _buildCard(
            title: 'Sao Lưu & Khôi Phục',
            icon: Icons.backup,
            iconColor: Colors.blue,
            children: [
              const Text(
                'Export dữ liệu ra file JSON để backup hoặc import từ file backup.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportData,
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text('Export Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _importData,
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Import Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Member List (Static)
          _buildCard(
            title: 'Danh Sách Thành Viên',
            icon: null,
            children: [
              _buildMemberRow(
                  'Chồng', 'assets/images/user1.png'), // Placeholder asset
              const SizedBox(height: 12),
              _buildMemberRow('Vợ', 'assets/images/user2.png'),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Reset Data (Moved to bottom)
          TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: _confirmReset,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Reset Dữ Liệu Demo')),
          const SizedBox(height: 20),
          if (_version.isNotEmpty)
            Center(
              child: Text(
                'Phiên bản: $_version',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );

    if (isTablet) {
      return SettingsPageIpad(child: body);
    }
    return SettingsPageMobile(child: body);
  }

  Widget _buildCard(
      {required String title,
      IconData? icon,
      Color? iconColor,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
              ],
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238))),
            ],
          ),
          const SizedBox(height: 12),
          ...children
        ],
      ),
    );
  }

  Widget _buildBudgetRow(BuildContext context, Budget budget) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(budget.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15)),
              const SizedBox(height: 4),
              Text(format.format(budget.amount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.deepOrange)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () {
              if (budget.id != null) {
                context.read<BudgetBloc>().add(DeleteBudgetEvent(budget.id!));
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildRecurringRow(BuildContext context, RecurringTransaction t) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '');
    final isExpense = t.type == 1;

    // Find the category for this recurring transaction
    final category = _categories.firstWhere(
      (c) => c.id == t.categoryId,
      orElse: () => Category(
        id: 0,
        name: 'Unknown',
        type: 0,
        icon: '❓',
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Category Icon (Emoji)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: isExpense ? Colors.orange[50] : Colors.green[50],
                shape: BoxShape.circle),
            child: Center(
              child: Text(
                category.icon ?? '📝',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.note ?? 'Khoản cố định',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  'Ngày ${t.dayOfMonth} hàng tháng',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${isExpense ? '-' : '+'}${CurrencyFormatter.formatCompact(t.amount)}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red : Colors.green,
                fontSize: 15),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () {
              if (t.id != null) {
                context
                    .read<RecurringTransactionBloc>()
                    .add(DeleteRecurringTransactionEvent(t.id!));
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, int type) {
    final isSelected = _recurringType == type;
    // Chi tiêu (type 1) = Red, Thu nhập (type 0) = Green
    final selectedColor =
        type == 1 ? AppColors.errorRed : AppColors.successGreen;
    final unselectedColor = Colors.grey[300]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _recurringType = type;
        });
      },
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

  Widget _buildMemberRow(String name, String asset) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 20,
          // backgroundImage: AssetImage(asset), // No assets yet
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      ],
    );
  }

  void _addBudget() {
    final amount = ThousandsSeparatorInputFormatter.parseFormattedNumber(
        _budgetAmountController.text);
    if (amount != null && _budgetNameController.text.isNotEmpty) {
      final now = DateTime.now();
      final budget = Budget(
        name: _budgetNameController.text,
        amount: amount,
        categoryId: 1, // Default for now
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
      );
      context.read<BudgetBloc>().add(AddBudgetEvent(budget));
      _budgetNameController.clear();
      _budgetAmountController.clear();
    }
  }

  void _addRecurring() {
    final amount = ThousandsSeparatorInputFormatter.parseFormattedNumber(
        _recurringAmountController.text);
    if (amount != null &&
        _recurringNameController.text.isNotEmpty &&
        _selectedCategoryId != null) {
      final rt = RecurringTransaction(
        amount: amount,
        type: _recurringType, // 1: Expense, 0: Income
        categoryId: _selectedCategoryId!, // Use selected category
        dayOfMonth: _recurringDayOfMonth, // Use selected day
        note: _recurringNameController.text,
      );
      context
          .read<RecurringTransactionBloc>()
          .add(AddRecurringTransactionEvent(rt));
      _recurringNameController.clear();
      _recurringAmountController.clear();
      setState(() {
        _recurringDayOfMonth = 1; // Reset to default
        _selectedCategoryId = null; // Reset category selection
      });
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
    }
  }

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final clearDataUseCase = di.sl<ClearDataUseCase>();
        await clearDataUseCase();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dữ liệu đã được xóa')));

          context.read<TransactionBloc>().add(LoadTransactions());
          context.read<BudgetBloc>().add(LoadBudgets());
          context
              .read<RecurringTransactionBloc>()
              .add(LoadRecurringTransactions());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Lỗi khi xóa dữ liệu: $e')));
        }
      }
    }
  }

  Future<void> _exportData() async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang export dữ liệu...')),
      );

      final isarService = di.sl<IsarService>();
      final exportService = DataExportService(isarService);

      final filePath = await exportService.exportData();

      if (filePath == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có dữ liệu để export')),
        );
        return;
      }

      // Share file
      final success = await exportService.shareExportedFile(filePath);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Export thành công!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi export: $e')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      // Confirm
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận Import'),
          content: const Text(
              'Import sẽ thêm dữ liệu từ file vào database hiện tại. Bạn có muốn tiếp tục?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Import')),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang import dữ liệu...')),
      );

      final isarService = di.sl<IsarService>();
      final importService = DataImportService(isarService);

      // Clear old data first for clean import
      await importService.clearAllData();

      final result = await importService.importData();

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${result.message}')),
        );

        // Reload data
        context.read<TransactionBloc>().add(LoadTransactions());
        context.read<BudgetBloc>().add(LoadBudgets());
        context
            .read<RecurringTransactionBloc>()
            .add(LoadRecurringTransactions());
        _loadCategories(); // Reload categories
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${result.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi import: $e')),
      );
    }
  }

  void _showDayPicker(BuildContext context) {
    int tempDay = _recurringDayOfMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const Text(
                      'Chọn ngày',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _recurringDayOfMonth = tempDay;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Xong'),
                    ),
                  ],
                ),
              ),
              // Picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _recurringDayOfMonth - 1,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    tempDay = index + 1;
                  },
                  children: List.generate(31, (index) {
                    final day = index + 1;
                    return Center(
                      child: Text(
                        'Ngày $day',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context) {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    // Filter categories by type
    final filteredCategories =
        _categories.where((c) => c.type == _recurringType).toList();

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
              Text(
                _recurringType == 1
                    ? 'Chọn danh mục chi tiêu'
                    : 'Chọn danh mục thu nhập',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filteredCategories.isEmpty
                    ? const Center(
                        child: Text("Chưa có danh mục nào",
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final isSelected = category.id == _selectedCategoryId;

                          final catColor = category.colorValue != null
                              ? Color(category.colorValue!)
                              : CategoryIcons.getColorByName(category.name);

                          Widget iconWidget = Text(
                            category.icon ?? '📁',
                            style: const TextStyle(fontSize: 24),
                          );

                          if (category.id != null) {
                            final staticMap =
                                CategoryIcons.getCategoryById(category.id!);
                            if (staticMap['id'] == category.id) {
                              final iconData = staticMap['icon'] as IconData;
                              if (category.icon ==
                                  String.fromCharCode(iconData.codePoint)) {
                                iconWidget =
                                    Icon(iconData, color: catColor, size: 24);
                              }
                            }
                          }

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: iconWidget,
                            ),
                            title: Text(category.name,
                                style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.black)),
                            trailing: isSelected
                                ? Icon(Icons.check,
                                    color: Theme.of(context).primaryColor)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
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
                      final isSelected = _quickShoppingBudgetId == null;
                      return ListTile(
                        leading: const Icon(Icons.account_balance_wallet,
                            color: Colors.grey),
                        title: const Text('Mặc định (Trừ vào tiền tổng)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: isSelected
                            ? Icon(Icons.check,
                                color: Theme.of(context).primaryColor)
                            : null,
                        onTap: () {
                          _saveQuickShoppingConfig(null);
                          Navigator.pop(context);
                        },
                      );
                    }

                    final budget = budgets[index - 1];
                    final isSelected = budget.id == _quickShoppingBudgetId;
                    return ListTile(
                      leading:
                          const Icon(Icons.track_changes, color: Colors.blue),
                      title: Text(budget.name),
                      subtitle:
                          Text(CurrencyFormatter.formatCompact(budget.amount)),
                      trailing: isSelected
                          ? Icon(Icons.check,
                              color: Theme.of(context).primaryColor)
                          : null,
                      onTap: () {
                        _saveQuickShoppingConfig(budget.id);
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
