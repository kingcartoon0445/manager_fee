import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AiService {
  final String apiKey;
  final String modelId;

  AiService({required this.apiKey, this.modelId = 'gemini-2.5-flash'});

  /// 1. Extract Transaction(s) from Natural Language Text using Gemini
  Future<List<Map<String, dynamic>>> extractTransactionFromText(
      String text) async {
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
      - "category_type": string (Choose EXACTLY one of these Vietnamese names: "Ăn uống", "Di chuyển", "Mua sắm", "Giải trí", "Giáo dục", "Hóa đơn", "Điện nước", "Nhà cửa", "Con cái", "Hiếu hỉ", "Bảo hiểm", "Sửa chữa", "Làm đẹp", "Thú cưng", "Gia đình", "Quà tặng", "Du lịch", "Chợ", "Thưởng", "Đầu tư", "Lương", "Khác")
      - "date": string (ISO8601 format YYYY-MM-DD, use current year $currentYear if year not specified, default to today $currentDate if date not found)
      
      Example Input: "cafe 30k, xăng 50k, ăn trưa 45k"
      Example JSON: [
        {"amount": 30000, "note": "cafe", "category_type": "Ăn uống", "date": "$currentDate"},
        {"amount": 50000, "note": "xăng", "category_type": "Di chuyển", "date": "$currentDate"},
        {"amount": 45000, "note": "ăn trưa", "category_type": "Ăn uống", "date": "$currentDate"}
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
      print('AI Text Extraction Error: $e');
      throw Exception('Failed to process text: $e');
    }
  }

  /// 2. OCR from Image using ML Kit
  Future<String> extractTextFromImage(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();
      return recognizedText.text;
    } catch (e) {
      print('OCR Error: $e');
      throw Exception('Failed to read text from image');
    }
  }

  /// 3. Extract Transaction from Receipt Image (OCR + Gemini)
  Future<Map<String, dynamic>> extractTransactionFromReceipt(
      XFile imageFile) async {
    // Step 1: Get raw text
    final rawText = await extractTextFromImage(imageFile);

    if (rawText.isEmpty) throw Exception("No text found in image");

    // Step 2: Ask Gemini to parse it
    try {
      final model = GenerativeModel(
        model: modelId,
        apiKey: apiKey,
      );

      final prompt = '''
      Analyze this receipt text and extract the total amount and merchant name.
      Receipt Text:
      """
      $rawText
      """
      
      Return a JSON object with:
      - "amount": number (total amount found, handle "thounds separators" like 100.000 or 100,000 correctly as 100000)
      - "note": string (Merchant name/Store name combined with main items if possible)
      - "category_type": string (guess category based on items: "Food", "Shopping", "Bills", "Transport", "Other")
      - "date": string (ISO8601 format YYYY-MM-DD found in receipt, default to today if not found)

      Only return JSON.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) throw Exception("No response from AI");

      String jsonStr =
          response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      return json.decode(jsonStr);
    } catch (e) {
      print('AI Receipt Analysis Error: $e');
      throw Exception('Failed to analyze receipt');
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
