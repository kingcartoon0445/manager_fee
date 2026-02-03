import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('⚠️  Vui lòng cung cấp API Key.');
    print('👉 Cách dùng: dart scripts/list_models.dart <YOUR_API_KEY>');
    return;
  }

  final apiKey = args[0];
  final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  final client = HttpClient();

  print('🔄 Đang kiểm tra danh sách models...');

  try {
    final request = await client.getUrl(url);
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody);
      final models = json['models'] as List;

      print('\n=============================================');
      print('✅ DANH SÁCH MODELS KHẢ DỤNG:');
      print('=============================================');

      for (var model in models) {
        final name = model['name'].toString().replaceAll('models/', '');
        final displayName = model['displayName'] ?? name;
        final methods =
            List<String>.from(model['supportedGenerationMethods'] ?? []);

        if (methods.contains('generateContent')) {
          print('🔹 $name ($displayName)');
        }
      }
      print('=============================================\n');
    } else {
      print('❌ Lỗi: ${response.statusCode} ${response.reasonPhrase}');
      final responseBody = await response.transform(utf8.decoder).join();
      print('Chi tiết: $responseBody');
    }
  } catch (e) {
    print('❌ Lỗi kết nối: $e');
  } finally {
    client.close();
  }
}
