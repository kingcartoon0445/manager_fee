import 'package:flutter/material.dart';
import '../../widgets/ai_chat_panel.dart';

class AiChatPage extends StatelessWidget {
  final bool autoStartListening;

  const AiChatPage({super.key, this.autoStartListening = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trợ lý AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Future: Add Clear Chat button here if needed
          // IconButton(
          //   icon: const Icon(Icons.delete_outline, color: Colors.black54),
          //   onPressed: () {
          //     // Clear chat logic
          //   },
          // ),
        ],
      ),
      body: AiChatPanel(autoStartListening: autoStartListening),
    );
  }
}
