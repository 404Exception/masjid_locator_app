import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart' as authProvider;
import '../models/masjid_submission.dart';

class MasjidProvider with ChangeNotifier {
  List<MasjidSubmission> _offices = [];
  List<MasjidSubmission> _filteredOffices = [];
  bool _isLoading = false;
  String _error = '';

  List<MasjidSubmission> get offices => _filteredOffices;
  bool get isLoading => _isLoading;
  String get error => _error;

  //   Future<void> fetchNearbyOffices(double lat, double lng, {double radius = 10}) async {
  //     _isLoading = true;
  //     _error = '';
  //     notifyListeners();

  //     try {
  //       final response = await http.get(
  //         Uri.parse('http://localhost:5074/api/Masjid/nearby?lat=$lat&lng=$lng&radius=$radius'),
  //         headers: {'Content-Type': 'application/json'},
  //       );

  //       if (response.statusCode == 200) {
  //         final List<dynamic> data = json.decode(response.body);
  //         _offices = data.map((json) => MasjidSubmission.fromJson(json)).toList();
  //         _filteredOffices = _offices;
  //         _error = '';
  //       } else {
  //         _error = 'Failed to load offices';
  //       }
  //     } catch (e) {
  //       _error = 'Error fetching offices: $e';
  //     } finally {
  //       _isLoading = false;
  //       notifyListeners();
  //     }
  //   }

  Future<void> fetchNearbyOffices(
    double lat,
    double lng, {
    double radius = 10,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
      //   final headers = authProvider.getAuthHeaders();

      // Get auth token directly from shared preferences or auth provider
      final token = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(
          'http://localhost:5074/api/Masjid/nearby?lat=$lat&lng=$lng&radius=$radius',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Handle both array and single object responses
        if (responseData is List) {
          final dynamic abc = responseData
              .map((json) => MasjidSubmission.fromJson(json))
              .toList();
              _offices = abc;
        } else if (responseData is Map<String, dynamic>) {
          _offices = [MasjidSubmission.fromJson(responseData)];
        } else {
          throw FormatException(
            'Invalid response format: ${responseData.runtimeType}',
          );
        }
        _filteredOffices = _offices;
        _error = '';
      } else if (response.statusCode == 401) {
        _error = 'Please login again';
        //authProvider.logout();
      } else {
        _error = 'Failed to load offices';
      }
    } catch (e) {
      _error = 'Error fetching offices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    // Use shared_preferences to get the token
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchOfficesByCity(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5074/api/Masjid/city?city=$city'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Handle both array and single object responses
        if (responseData is List) {
          _offices = responseData
              .map((json) => MasjidSubmission.fromJson(json))
              .toList();
        } else if (responseData is Map<String, dynamic>) {
          _offices = [MasjidSubmission.fromJson(responseData)];
        } else {
          throw FormatException(
            'Invalid response format: ${responseData.runtimeType}',
          );
        }
        _filteredOffices = _offices;
        _error = '';
      } else {
        _error = 'Failed to load offices';
      }
    } catch (e) {
      _error = 'Error fetching offices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterOffices(String query) {
    if (query.isEmpty) {
      _filteredOffices = _offices;
    } else {
      _filteredOffices = _offices
          .where(
            (office) =>
                office.name.toLowerCase().contains(query.toLowerCase()) ||
                office.city.toLowerCase().contains(query.toLowerCase()) ||
                office.address.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }
}
