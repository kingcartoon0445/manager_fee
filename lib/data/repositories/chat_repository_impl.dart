import 'package:isar/isar.dart';
import '../../data/datasources/isar_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final IsarService isarService;

  ChatRepositoryImpl(this.isarService);

  @override
  Future<List<ChatMessageModel>> getMessagesForToday() async {
    final isar = await isarService.db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.chatMessageModels
        .filter()
        .timestampBetween(startOfDay, endOfDay)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<void> addMessage({
    required String text,
    required bool isUser,
    bool isSystem = false,
    String? imagePath,
    String? transactionJson,
  }) async {
    final isar = await isarService.db;
    final message = ChatMessageModel()
      ..text = text
      ..isUser = isUser
      ..isSystem = isSystem
      ..timestamp = DateTime.now()
      ..imagePath = imagePath
      ..transactionJson = transactionJson;

    await isar.writeTxn(() async {
      await isar.chatMessageModels.put(message);
    });
  }

  @override
  Future<void> updateMessage(ChatMessageModel message) async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.chatMessageModels.put(message);
    });
  }

  @override
  Future<void> cleanupOldMessages() async {
    final isar = await isarService.db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    await isar.writeTxn(() async {
      // Delete all messages before today
      await isar.chatMessageModels
          .filter()
          .timestampLessThan(startOfDay)
          .deleteAll();
    });
  }

  @override
  Future<void> clearAll() async {
    final isar = await isarService.db;
    await isar.writeTxn(() async {
      await isar.chatMessageModels.clear();
    });
  }
}
