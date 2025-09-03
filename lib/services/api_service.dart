import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:masjid_locator_app/constants/environment.dart';

class ApiService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    return jsonDecode(response.body);
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      return response;
    } catch (e) {
      // Handle other errors (network, json decode, etc.)
      throw Exception('Failed to make POST request: $e');
    }
  }
}
