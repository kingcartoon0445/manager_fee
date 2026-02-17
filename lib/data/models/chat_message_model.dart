import 'package:isar/isar.dart';

part 'chat_message_model.g.dart';

@collection
class ChatMessageModel {
  Id id = Isar.autoIncrement;

  late String text;

  late bool isUser;

  late DateTime timestamp;

  bool isSystem = false;

  // Optional: Store transaction details JSON string if needed for UI reconstruction
  // For now, simpler is better. System messages will just be text logs.
  String? transactionJson;

  String? imagePath;
}
