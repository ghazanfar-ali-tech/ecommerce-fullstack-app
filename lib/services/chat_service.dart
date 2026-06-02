import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerceapp/core/constants.dart';

class ChatService {
  static const String baseUrl = AppConstants.baseUrl;

  static Future<Map<String, dynamic>> sendMessage(
    String text,
    String? sessionId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          if (sessionId != null) 'session_id': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with Chat API: $e');
    }
  }

  static Future<List<dynamic>> getHistory(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$sessionId/history/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }
}
