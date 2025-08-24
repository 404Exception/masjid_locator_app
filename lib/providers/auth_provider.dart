import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userEmail;
  String? _userName;
  bool _isAdmin = false;
  bool _isLoading = false;
  String _error = '';

  String? get token => _token;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isAdmin => _isAdmin;
  bool get isAuth => _token != null;
  bool get isLoading => _isLoading;
  String get error => _error;

  static const String _apiUrl = 'http://localhost:5074/api/Auth';

  // Initialize auth from shared preferences
  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _isAdmin = prefs.getBool('isAdmin') ?? false;
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['token'];
        _userId = responseData['userId'];
        _isAdmin = responseData['isAdmin'] ?? false;

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        prefs.setString('userId', _userId!);
        prefs.setBool('isAdmin', _isAdmin);

        // Fetch user details if needed
        //await _fetchUserDetails();

        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register method
  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 200) {
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Password reset failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Password reset error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userEmail = null;
    _userName = null;
    _isAdmin = false;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userId');
    prefs.remove('userEmail');
    prefs.remove('userName');
    prefs.remove('isAdmin');

    notifyListeners();
  }

  // Get authenticated HTTP headers
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  // Fetch user details
  // Future<void> _fetchUserDetails() async {
  //   if (_token == null) return;

  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_apiUrl/user-details'),
  //       headers: getAuthHeaders(),
  //     );

  //     if (response.statusCode == 200) {
  //       final userData = json.decode(response.body);
  //       _userEmail = userData['email'];
  //       _userName = userData['fullName'];
        
  //       final prefs = await SharedPreferences.getInstance();
  //       prefs.setString('userEmail', _userEmail!);
  //       prefs.setString('userName', _userName!);
        
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     print('Error fetching user details: $e');
  //   }
  // }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}