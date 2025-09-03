import 'package:http/http.dart' as http;

import 'api_service.dart';

class AuthService {
  final ApiService api;

  AuthService({required this.api});

  Future<http.Response> login(String email, String password) async {
    return await api.post('Auth/login', {'email': email, 'password': password});
  }
}
