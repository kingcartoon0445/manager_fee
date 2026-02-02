import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class AiService {
  final String apiKey;

  AiService({required this.apiKey});

  /// 1. Extract Transaction from Natural Language Text using Gemini
  Future<Map<String, dynamic>> extractTransactionFromText(String text) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      final prompt = '''
      Extract transaction details from the following text: "$text"
      Return a JSON object with these fields:
      - "amount": number (integer, if not found return 0)
      - "note": string (short description)
      - "category_type": string (either "Food", "Transport", "Shopping", "Entertainment", "Education", "Bills", "Income", "Other")
      - "date": string (ISO8601 format YYYY-MM-DD, assume current year if not specified, default to today if not found)
      
      Example Input: "Morning coffee 30k"
      Example JSON: {"amount": 30000, "note": "Morning coffee", "category_type": "Food", "date": "2023-10-27"}
      
      Only return the JSON object, no code blocks or extra text.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) throw Exception("No response from AI");

      // Clean up response if it contains markdown code blocks
      String jsonStr =
          response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(jsonStr);
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
        model: 'gemini-pro',
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
}
