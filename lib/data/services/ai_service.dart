import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AiService {
  final String apiKey;
  final String modelId;

  AiService({required this.apiKey, this.modelId = 'gemini-2.5-flash'});

  /// 1. Extract Transaction(s) from Natural Language Text using Gemini
  Future<List<Map<String, dynamic>>> extractTransactionFromText(
      String text, List<String> categoryNames) async {
    try {
      final currentYear = DateTime.now().year;
      final currentDate =
          DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

      final model = GenerativeModel(
        model: modelId,
        apiKey: apiKey,
      );

      final prompt = '''
      Extract ALL transaction details from the following text: "$text"
      The text may contain one or multiple transactions separated by commas or other punctuation.
      
      Return a JSON ARRAY of transaction objects. Each object should have these fields:
      - "amount": number (integer, if not found return 0)
      - "note": string (short description)
      - "type": string (Classify as "income" (thu nhập) or "expense" (chi tiêu). Default "expense" if unsure.)
      - "category_type": string (Choose EXACTLY one of these Vietnamese names: "${categoryNames.join('", "')}")
      - "date": string (ISO8601 format YYYY-MM-DD, use current year $currentYear if year not specified, default to today $currentDate if date not found)
      
      Example Input: "cafe 30k, lương 20 triệu"
      Example JSON: [
        {"amount": 30000, "note": "cafe", "type": "expense", "category_type": "Ăn uống", "date": "$currentDate"},
        {"amount": 20000000, "note": "lương", "type": "income", "category_type": "Lương", "date": "$currentDate"}
      ]
      
      If there is only one transaction, still return an array with one element.
      Only return the JSON array, no code blocks or extra text.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) throw Exception("No response from AI");

      // Clean up response if it contains markdown code blocks
      String jsonStr =
          response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      final decoded = json.decode(jsonStr);

      // Ensure we always return a list
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map) {
        // If AI returns a single object instead of array, wrap it
        return [Map<String, dynamic>.from(decoded)];
      } else {
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      debugPrint('AI Text Extraction Error: $e');
      throw Exception('Failed to process text: $e');
    }
  }

  Future<Map<String, dynamic>> extractTransactionFromReceipt(
      XFile imageFile, List<String> categoryNames) async {
    try {
      final model = GenerativeModel(
        model:
            modelId, // Use the configured model (flash recommended for images)
        apiKey: apiKey,
      );

      final imageBytes = await imageFile.readAsBytes();
      final prompt = '''
      Analyze this receipt image and extract the total amount and merchant name.
      
      Return a STRICT JSON Object with these fields:
      - "amount": number (total amount found, handle "thousands separators" like 100.000 or 100,000 correctly as 100000. Ignore currency symbols like "đ", "VND")
      - "note": string (Merchant name/Store name combined with main items if possible. Keep it short.)
      - "category_type": string (Choose EXACTLY one of these: "${categoryNames.join('", "')}")
      - "date": string (ISO8601 format YYYY-MM-DD found in receipt. If strictly not found, use today's date)

      Example JSON:
      {
        "amount": 150000,
        "note": "Highlands Coffee - Cafe sữa",
        "category_type": "Ăn uống",
        "date": "2024-05-20"
      }

      Only return the clean JSON object. No markdown formatting.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes), // Assuming jpeg/png
        ])
      ];

      final response = await model.generateContent(content);

      if (response.text == null) throw Exception("No response from AI");

      String jsonStr =
          response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      // Cleanup cleanup: sometimes there are extra characters
      final startIndex = jsonStr.indexOf('{');
      final endIndex = jsonStr.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        jsonStr = jsonStr.substring(startIndex, endIndex + 1);
      }

      return json.decode(jsonStr);
    } catch (e) {
      debugPrint('AI Receipt Analysis Error: $e');
      throw Exception('Failed to analyze receipt: $e');
    }
  }

  /// 4. Get Available Models
  static Future<List<Map<String, String>>> getAvailableModels(
      String apiKey) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
    final client = HttpClient();
    final List<Map<String, String>> availableModels = [];

    try {
      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);
        final models = json['models'] as List;

        for (var model in models) {
          final name = model['name'].toString().replaceAll('models/', '');
          final displayName = model['displayName'] ?? name;
          final methods =
              List<String>.from(model['supportedGenerationMethods'] ?? []);

          if (methods.contains('generateContent')) {
            availableModels.add({'id': name, 'name': displayName});
          }
        }
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching models: $e');
    } finally {
      client.close();
    }

    // Sort logic? Optional.
    return availableModels;
  }
}
