import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert'; // Added for JSON
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/services/ai_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart'; // Added state
import '../../domain/repositories/app_settings_repository.dart';
import '../../domain/repositories/chat_repository.dart'; // Added ChatRepository
import '../../../injection_container.dart' as di;
import 'privacy_consent_dialog.dart';
import '../../domain/entities/app_settings.dart';

class AiChatPanel extends StatefulWidget {
  final bool autoStartListening;
  const AiChatPanel({super.key, this.autoStartListening = false});

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speechToText = SpeechToText();
  final ChatRepository _chatRepository = di.sl<ChatRepository>(); // Inject Repo

  List<ChatMessage> _messages = []; // Removed final
  bool _isLoading = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  String? _apiKey;
  String? _modelId;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _initChat(); // Load and cleanup
    if (widget.autoStartListening) {
      Future.delayed(const Duration(milliseconds: 500), _toggleListening);
    }
  }

  Future<void> _initChat() async {
    await _chatRepository.cleanupOldMessages();
    await _loadMessagesFromDb();
  }

  Future<void> _loadMessagesFromDb() async {
    final dbMessages = await _chatRepository.getMessagesForToday();
    if (!mounted) return;

    setState(() {
      _messages = dbMessages.map((m) {
        List<Map<String, dynamic>>? transactions;
        if (m.transactionJson != null) {
          try {
            final List<dynamic> decoded = jsonDecode(m.transactionJson!);
            transactions =
                decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          } catch (e) {
            debugPrint('Error decoding transactions: $e');
          }
        }

        return ChatMessage(
          id: m.id,
          text: m.text,
          isUser: m.isUser,
          isSystem: m.isSystem,
          imageFile: m.imagePath != null ? XFile(m.imagePath!) : null,
          transactions: transactions,
        );
      }).toList();

      // Add default greeting if empty
      if (_messages.isEmpty) {
        _messages.add(ChatMessage(
          text:
              'Chào bạn! Mình là trợ lý AI.\nBạn có thể nhập liệu nhanh như: "Ăn sáng 30k", "Cafe 25k"... hoặc gửi ảnh hóa đơn.',
          isUser: false,
        ));
      }
    });

    // Scroll to bottom after loading
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _loadApiKey() async {
    final settingsRepo = di.sl<AppSettingsRepository>();
    final settings = await settingsRepo.getAppSettings();
    if (mounted) {
      setState(() {
        _apiKey = settings?.geminiApiKey;
        _modelId = settings?.geminiModelId ?? 'gemini-2.5-flash';
      });
    }
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (e) => debugPrint('Speech Error: $e'),
      onStatus: (status) {
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
        await _initSpeech();
        if (!_speechEnabled) return;
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _normalizeStr(String s) {
    var str = s.toLowerCase().trim();
    // Manual mapping for common Vietnamese chars to unaccented
    // faster than importing a package just for this
    final vietnamese =
        'aáàảãạăắằẳẵặâấầẩẫậeéèẻẽẹêếềểễệiíìỉĩịoóòỏõọôốồổỗộơớờởỡợuúùủũụưứừửữựyýỳỷỹỵdđ';
    final latin =
        'aaaaaaaaaaaaaaaaaaeeeeeeeeeeeeiiiiiioooooooooooooooooouuuuuuuuuuuuyyyyyydd';
    for (int i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(vietnamese[i], latin[i]);
    }
    return str;
  }

  Future<List<String>> _getCategoryNames() async {
    final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();
    final categories = await getCategoriesUseCase();
    // Only get expense categories (type == 1)
    return categories.where((c) => c.type == 1).map((c) => c.name).toList();
  }

  Future<List<Map<String, dynamic>>> _enrichTransactions(
      List<Map<String, dynamic>> rawResults) async {
    final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();
    final allCategories = await getCategoriesUseCase();

    return rawResults.map((data) {
      final categoryTypeStr = data['category_type'] as String? ?? '';
      final typeStr = data['type'] as String? ?? 'expense';
      final type = typeStr.toLowerCase() == 'income' ? 0 : 1; // 0: Thu, 1: Chi

      // Filter categories based on type
      final categories = allCategories.where((c) => c.type == type).toList();

      Category? matchedCategory;

      if (categoryTypeStr.isNotEmpty && categories.isNotEmpty) {
        final searchStr = _normalizeStr(categoryTypeStr);

        // Priority 1: Exact match (normalized)
        try {
          matchedCategory = categories.firstWhere(
            (c) => _normalizeStr(c.name) == searchStr,
          );
        } catch (_) {}

        // Priority 2: Contains match
        if (matchedCategory == null) {
          try {
            matchedCategory = categories.firstWhere(
              (c) =>
                  _normalizeStr(c.name).contains(searchStr) ||
                  searchStr.contains(_normalizeStr(c.name)),
            );
          } catch (_) {}
        }
      }

      // Fallback
      if (matchedCategory == null && categories.isNotEmpty) {
        // Try to find 'Khác' or just take first
        matchedCategory = categories.firstWhere(
            (c) => c.name.toLowerCase().contains('khác'),
            orElse: () => categories.first);
      }

      final newMap = Map<String, dynamic>.from(data);
      newMap['type'] = type; // Save parsed type (0 or 1)
      if (matchedCategory != null) {
        newMap['categoryId'] = matchedCategory.id;
        newMap['categoryName'] = matchedCategory.name;
        newMap['categoryIcon'] = matchedCategory.icon;
      }
      return newMap;
    }).toList();
  }

  Future<bool> _checkAndRequestConsent() async {
    final settingsRepo = di.sl<AppSettingsRepository>();
    var settings = await settingsRepo.getAppSettings();

    if (settings?.isAiConsentGiven == true) return true;

    // Show consent dialog
    if (!mounted) return false;
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PrivacyConsentDialog(),
    );

    if (result == true && settings != null) {
      // Save consent
      final newSettings = AppSettings(
        id: settings.id,
        hasCompletedOnboarding: settings.hasCompletedOnboarding,
        onboardingCompletedAt: settings.onboardingCompletedAt,
        initialBalance: settings.initialBalance,
        lastClosedMonth: settings.lastClosedMonth,
        geminiApiKey: settings.geminiApiKey,
        geminiModelId: settings.geminiModelId,
        isAiConsentGiven: true,
      );
      await settingsRepo.saveAppSettings(newSettings);
      return true;
    }

    return false;
  }

  Future<void> _handleSend() async {
    if (_textController.text.trim().isEmpty) return;

    // Check consent first
    final hasConsent = await _checkAndRequestConsent();
    if (!hasConsent) return;

    if (_apiKey == null || _apiKey!.isEmpty) {
      _addSystemMessage('Vui lòng nhập API Key trong Cài đặt trước.');
      return;
    }

    final userText = _textController.text;
    _textController.clear();

    // Save to DB and update UI
    await _chatRepository.addMessage(text: userText, isUser: true);
    await _loadMessagesFromDb();

    setState(() {
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final aiService = AiService(apiKey: _apiKey!, modelId: _modelId!);
      final categoryNames = await _getCategoryNames();
      final results =
          await aiService.extractTransactionFromText(userText, categoryNames);
      final enrichedResults = await _enrichTransactions(results);
      _handleAiResults(enrichedResults);
    } catch (e) {
      _addSystemMessage(
          'Lỗi: $e'); // System message not persisted usually? Or should convert to persist?
      // Not persisting error messages for now to keep DB clean
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // Check consent first
    final hasConsent = await _checkAndRequestConsent();
    if (!hasConsent) return;

    if (_apiKey == null || _apiKey!.isEmpty) {
      _addSystemMessage('Vui lòng nhập API Key trong Cài đặt trước.');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      // Save image message to DB
      await _chatRepository.addMessage(
        text: '[Đã gửi ảnh hóa đơn]',
        isUser: true,
        imagePath: image.path,
      );
      await _loadMessagesFromDb();

      setState(() {
        _isLoading = true;
      });
      _scrollToBottom();

      final aiService = AiService(apiKey: _apiKey!, modelId: _modelId!);
      final categoryNames = await _getCategoryNames();
      final result =
          await aiService.extractTransactionFromReceipt(image, categoryNames);
      final enrichedResults = await _enrichTransactions([result]);
      _handleAiResults(enrichedResults);
    } catch (e) {
      _addSystemMessage('Lỗi xử lý ảnh: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _handleAiResults(List<Map<String, dynamic>> results) async {
    if (results.isEmpty) {
      _addSystemMessage('Không tìm thấy thông tin giao dịch nào.');
      return;
    }

    // Save AI response to DB
    await _chatRepository.addMessage(
      text: 'Tìm thấy ${results.length} giao dịch:',
      isUser: false,
      transactionJson: jsonEncode(results),
    );
    await _loadMessagesFromDb();
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false, isError: true));
    });
  }

  Future<void> _saveTransaction(
      Map<String, dynamic> data, ChatMessage msg, int index) async {
    try {
      final addTransactionUseCase = di.sl<AddTransactionUseCase>();
      // Use enriched Category ID if available, else lookup (fallback)
      final categoryId = data['categoryId'] as int? ?? 1;

      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final note = data['note'] as String? ?? '';
      final dateStr = data['date'] as String?;

      // Parse date and add current time
      final now = DateTime.now();
      DateTime date = now;
      if (dateStr != null) {
        final parsedDate = DateTime.tryParse(dateStr);
        if (parsedDate != null) {
          date = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
            now.hour,
            now.minute,
          );
        }
      }

      final type = data['type'] as int? ?? 1; // Default to Expense if missing

      final transaction = entity.Transaction(
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        note: note,
        tags: [],
        budgetId: null,
      );

      // We use the Bloc to add transaction so that it triggers the system message log in DB
      // and also refreshes the dashboard/transaction list
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));

      // Update message state
      if (msg.transactions != null && msg.id != null) {
        final updatedTransactions =
            List<Map<String, dynamic>>.from(msg.transactions!);
        updatedTransactions[index] = {...data, 'isSaved': true};

        try {
          final chatRepo = di.sl<ChatRepository>();
          final messages = await chatRepo.getMessagesForToday();
          final modelToUpdate = messages.firstWhere((m) => m.id == msg.id);

          modelToUpdate.transactionJson = jsonEncode(updatedTransactions);
          await chatRepo.updateMessage(modelToUpdate);

          // Reload UI
          await _loadMessagesFromDb();
        } catch (e) {
          debugPrint('Error updating message state: $e');
        }
      }

      // Show snippet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đã lưu giao dịch thành công'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi khi lưu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          // Refresh messages when transactions are reloaded (implies add/update)
          _loadMessagesFromDb();
        }
      },
      child: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isLoading) const LinearProgressIndicator(minHeight: 2),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image_outlined, color: Colors.grey),
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Nhập giao dịch...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _handleSend(),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                if (_textController.text.isNotEmpty)
                  IconButton(
                    onPressed: _handleSend,
                    icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                  )
                else
                  IconButton(
                    onPressed: _toggleListening,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    final isSystem = msg.isSystem;

    // System message styling (e.g., "Added transaction")
    if (isSystem) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        alignment: Alignment.center,
        child: Text(
          msg.text,
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (msg.imageFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 200,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: FileImage(File(msg.imageFile!.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (msg.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryBlue : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          if (msg.transactions != null)
            ...msg.transactions!.asMap().entries.map(
                (entry) => _buildTransactionCard(entry.value, msg, entry.key)),
          if (msg.isError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('⚠️ ${msg.text}',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      Map<String, dynamic> tx, ChatMessage msg, int index) {
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
    final note = tx['note'] ?? '';
    final categoryName = tx['categoryName'] ?? 'Chưa phân loại';
    final categoryIcon = tx['categoryIcon'] ?? '❓';
    final isSaved = tx['isSaved'] == true;
    final type = tx['type'] as int? ?? 1; // 1: Expense, 0: Income

    // Income gets a light blue tint, Expense is white
    final backgroundColor = type == 0 ? const Color(0xFFE1F5FE) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 8, right: 40),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isSaved ? Colors.green[100]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSaved ? Colors.green[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  categoryIcon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(amount),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryBlue,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (note.toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                note.toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isSaved ? null : () => _saveTransaction(tx, msg, index),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaved ? Colors.green : AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.green.withOpacity(0.8),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
                visualDensity: VisualDensity.compact,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSaved) ...[
                    const Icon(Icons.check, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(isSaved ? 'Đã lưu' : 'Lưu giao dịch'),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn();
  }
}

class ChatMessage {
  final int? id; // Added ID
  final String text;
  final bool isUser;
  final bool isError;
  final bool isSystem;
  final List<Map<String, dynamic>>? transactions;
  final XFile? imageFile;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    this.isError = false,
    this.isSystem = false,
    this.transactions,
    this.imageFile,
  });
}
