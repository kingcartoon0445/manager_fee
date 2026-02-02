import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/services/ai_service.dart';

import '../../../domain/repositories/app_settings_repository.dart';
import '../../../injection_container.dart' as di;
import 'add_transaction_modal.dart';

class AiInputModal extends StatefulWidget {
  const AiInputModal({super.key});

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

  // Analysis Result State
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final settingsRepo = di.sl<AppSettingsRepository>();
    final settings = await settingsRepo.getAppSettings();
    setState(() {
      _apiKey = settings?.geminiApiKey;
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
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _analysisResult = null;
    });

    try {
      final aiService = AiService(apiKey: _apiKey!);
      final result =
          await aiService.extractTransactionFromText(_textController.text);
      _handleAiResult(result);
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
        _analysisResult = null;
      });

      final aiService = AiService(apiKey: _apiKey!);
      final result = await aiService.extractTransactionFromReceipt(image);
      _handleAiResult(result);
    } catch (e) {
      debugPrint('AI Error: $e'); // Log error to console
      setState(() {
        _error = 'Lỗi xử lý ảnh: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAiResult(Map<String, dynamic> result) {
    // Map AI category string to local Category

    // This is simple mapping. Real app might match by name similarity
    // Or we leave it empty for user to select.

    // For now, let's just confirm displaying.
    setState(() {
      _analysisResult = result;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmTransaction() {
    if (_analysisResult == null) return;

    final amount = (_analysisResult!['amount'] as num?)?.toDouble() ?? 0;
    final note = _analysisResult!['note'] as String? ?? '';
    final dateStr = _analysisResult!['date'] as String?;
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
        // We could pass categoryId if we successfully mapped it
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send),
                          label: Text(
                              _isLoading ? 'Đang phân tích...' : 'Phân tích'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      if (_analysisResult != null) _buildResultCard(),
                    ],
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
                      if (_analysisResult != null)
                        Expanded(
                            child: SingleChildScrollView(
                                child: _buildResultCard())),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildResultCard() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final amount = (_analysisResult!['amount'] as num?)?.toDouble() ?? 0;
    final note = _analysisResult!['note'] ?? '';
    final category = _analysisResult!['category_type'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kết quả phân tích:",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.green, size: 20),
              Text(CurrencyFormatter.format(amount),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.note, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(note.toString(),
                      style: const TextStyle(fontSize: 16))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text("Gợi ý: $category",
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Tạo giao dịch này"),
            ),
          )
        ],
      ),
    );
  }
}
