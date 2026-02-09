import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/services/ai_service.dart';
import '../../../domain/entities/transaction.dart' as entity;
import '../../../domain/usecases/add_transaction_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';

import '../../../domain/repositories/app_settings_repository.dart';
import '../../../injection_container.dart' as di;
import 'add_transaction_modal.dart';

class AiInputModal extends StatefulWidget {
  final bool autoStartListening;
  const AiInputModal({super.key, this.autoStartListening = false});

  @override
  State<AiInputModal> createState() => _AiInputModalState();
}

class _AiInputModalState extends State<AiInputModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _error;
  String? _apiKey;
  String? _modelId;

  // Speech to Text
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  // Analysis Result State
  List<Map<String, dynamic>>? _analysisResults;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadApiKey();
    // _initSpeech(); // Removed: Load on demand
    if (widget.autoStartListening) {
      // Delay slightly to ensure UI is ready and permissions are checked by _initSpeech
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _toggleListening();
      });
    }
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (e) => debugPrint('Speech Error: $e'),
      onStatus: (status) {
        debugPrint('Speech Status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      if (!_speechEnabled) {
        await _initSpeech(); // Try init again (calls permission request)
        if (!_speechEnabled) {
          _showError(
              'Không thể khởi động nhận diện giọng nói. Vui lòng cấp quyền.');
          return;
        }
      }

      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        },
        localeId: 'vi_VN',
      );
    }
  }

  Future<void> _loadApiKey() async {
    final settingsRepo = di.sl<AppSettingsRepository>();
    final settings = await settingsRepo.getAppSettings();
    setState(() {
      _apiKey = settings?.geminiApiKey;
      _modelId = settings?.geminiModelId ?? 'gemini-2.5-flash';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processText() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _showError('Vui lòng nhập API Key trong Cài đặt trước.');
      return;
    }
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _analysisResults = null;
    });

    try {
      final aiService =
          AiService(apiKey: _apiKey!, modelId: _modelId ?? 'gemini-1.5-flash');
      final results =
          await aiService.extractTransactionFromText(_textController.text);
      _handleAiResult(results);
    } catch (e) {
      debugPrint('AI Error: $e'); // Log error to console
      setState(() {
        _error = 'Lỗi xử lý: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _showError('Vui lòng nhập API Key trong Cài đặt trước.');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _error = null;
        _analysisResults = null;
      });

      final aiService =
          AiService(apiKey: _apiKey!, modelId: _modelId ?? 'gemini-1.5-flash');
      final result = await aiService.extractTransactionFromReceipt(image);
      // Wrap single receipt result in a list for consistency
      _handleAiResult([result]);
    } catch (e) {
      debugPrint('AI Error: $e'); // Log error to console
      setState(() {
        _error = 'Lỗi xử lý ảnh: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAiResult(List<Map<String, dynamic>> results) {
    setState(() {
      _analysisResults = results;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmTransaction(int index) {
    if (_analysisResults == null || index >= _analysisResults!.length) return;

    final transaction = _analysisResults![index];
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
    final note = transaction['note'] as String? ?? '';
    final dateStr = transaction['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();

    Navigator.pop(context); // Close AI Modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(
        initialAmount: amount,
        initialNote: note,
        initialDate: date,
      ),
    );
  }

  void _createAllTransactions() async {
    if (_analysisResults == null || _analysisResults!.isEmpty) return;

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo tất cả giao dịch?'),
        content: Text(
          'Bạn có muốn tạo ${_analysisResults!.length} giao dịch này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo tất cả',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Get the use cases directly from dependency injection
    final addTransactionUseCase = di.sl<AddTransactionUseCase>();
    final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();

    // Create all transactions directly without triggering events
    try {
      // Fetch categories once for mapping
      final categories = await getCategoriesUseCase();
      final expenseCategories = categories.where((c) => c.type == 1).toList();

      for (var result in _analysisResults!) {
        final amount = (result['amount'] as num?)?.toDouble() ?? 0;
        final note = result['note'] as String? ?? '';
        final dateStr = result['date'] as String?;
        final categoryTypeStr = result['category_type'] as String? ?? '';
        final date =
            dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();

        // Map AI category_type to actual categoryId
        int categoryId = 1; // Default fallback
        if (categoryTypeStr.isNotEmpty && expenseCategories.isNotEmpty) {
          // Try to find matching category by name (case-insensitive)
          final matchedCategory = expenseCategories.firstWhere(
            (c) =>
                c.name.toLowerCase().contains(categoryTypeStr.toLowerCase()) ||
                categoryTypeStr.toLowerCase().contains(c.name.toLowerCase()),
            orElse: () => expenseCategories.first,
          );
          categoryId = matchedCategory.id ?? 1;
        }

        // Create transaction with mapped category
        final transaction = entity.Transaction(
          amount: amount,
          type: 1, // Default to expense
          categoryId: categoryId,
          date: date ?? DateTime.now(),
          note: note,
          tags: [],
          budgetId: null,
        );

        // Call use case directly to save transaction
        await addTransactionUseCase(transaction);
      }

      if (mounted) {
        // Now reload transactions once after all are saved
        context.read<TransactionBloc>().add(LoadTransactions());

        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo ${_analysisResults!.length} giao dịch'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo giao dịch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Assistant ✨',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_apiKey == null)
                    const Text(
                      'Chưa có API Key',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Nhập câu', icon: Icon(Icons.keyboard)),
                Tab(text: 'Quét hóa đơn', icon: Icon(Icons.document_scanner)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Text Input Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: Ăn sáng 30k, Xăng 50k...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FD),
                              suffixIcon: IconButton(
                                onPressed: _toggleListening,
                                icon: _isListening
                                    ? const Icon(Icons.mic, color: Colors.red)
                                        .animate(
                                            onPlay: (controller) => controller
                                                .repeat(reverse: true))
                                        .scale(
                                            duration: 600.ms,
                                            begin: const Offset(1, 1),
                                            end: const Offset(1.2, 1.2))
                                    : const Icon(Icons.mic_none,
                                        color: Colors.grey),
                                tooltip: 'Nhập bằng giọng nói',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _processText,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.send),
                              label: Text(_isLoading
                                  ? 'Đang phân tích...'
                                  : 'Phân tích'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(_error!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          if (_analysisResults != null &&
                              _analysisResults!.isNotEmpty)
                            _buildResultCards(),
                        ],
                      ),
                    ),
                  ),

                  // Image Input Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            "Chụp hoặc chọn ảnh hóa đơn để AI tự điền thông tin",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSquareButton(
                                icon: Icons.camera_alt,
                                label: "Chụp ảnh",
                                onTap: () => _pickImage(ImageSource.camera)),
                            _buildSquareButton(
                                icon: Icons.photo_library,
                                label: "Thư viện",
                                onTap: () => _pickImage(ImageSource.gallery)),
                          ],
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: CircularProgressIndicator(),
                          ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        if (_analysisResults != null &&
                            _analysisResults!.isNotEmpty)
                          Expanded(
                              child: SingleChildScrollView(
                                  child: _buildResultCards())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.primaryBlue),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCards() {
    if (_analysisResults == null || _analysisResults!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tìm thấy ${_analysisResults!.length} giao dịch:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (_analysisResults!.length > 1)
                ElevatedButton.icon(
                  onPressed: _createAllTransactions,
                  icon: const Icon(Icons.add_circle, size: 18),
                  label: const Text('Tạo nhanh tất cả'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        ...List.generate(_analysisResults!.length, (index) {
          final transaction = _analysisResults![index];
          final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
          final note = transaction['note'] ?? '';
          final category = transaction['category_type'] ?? 'Unknown';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.monetization_on,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.note, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmTransaction(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Tạo giao dịch này'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
