import '../../data/models/chat_message_model.dart';
import '../../presentation/widgets/ai_chat_panel.dart'; // For ChatMessage UI model if needed, or better expose domain model

abstract class ChatRepository {
  Future<List<ChatMessageModel>> getMessagesForToday();
  Future<void> addMessage(
      {required String text,
      required bool isUser,
      bool isSystem = false,
      String? imagePath,
      String? transactionJson});
  Future<void> updateMessage(ChatMessageModel message);
  Future<void> cleanupOldMessages();
  Future<void> clearAll();
}
