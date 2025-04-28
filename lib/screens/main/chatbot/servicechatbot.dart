import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String apiKey = ''; // Ganti dengan API key dari OpenRouter

  Future<String> getBotReply(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'YOUR_SITE_URL', // Opsional, ganti dengan URL situsmu
          'X-Title': 'YOUR_SITE_NAME', // Opsional, ganti dengan nama situsmu
        },
        body: json.encode({
          'model': 'microsoft/mai-ds-r1:free', // Model gratis dari OpenRouter
          'messages': [
            {
              'role': 'user',
              'content': message,
            }
          ],
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Maaf, tidak ada respons.';
      } else {
        return 'Gagal memuat respons: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Maaf, terjadi kesalahan: $e';
    }
  }
}