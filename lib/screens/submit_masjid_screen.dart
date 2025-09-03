import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/environment.dart';

class SubmitMasjidScreen extends StatefulWidget {
  const SubmitMasjidScreen({super.key});
  @override
  State<SubmitMasjidScreen> createState() => _SubmitMasjidScreenState();
}

class _SubmitMasjidScreenState extends State<SubmitMasjidScreen> {
  @override
  void initState() {
    super.initState();
    init(); // call async method
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();
  String? _token;
  String? _userId;
  String? get token => _token;
  String? get userId => _userId;

  TimeOfDay _startTime = TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _endTime = TimeOfDay(hour: 13, minute: 10);
  Position? _currentPosition;
  bool _isSubmitting = false;

  static final String _apiUrl = '${AppConfig.baseUrl}/Submission';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _token = prefs.getString('token');
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  String _formatTimeForApi(TimeOfDay time) {
  // Convert to 24-hour format and ensure two digits
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute:00'; // API expects HH:mm:ss format
}

  Future<void> _submitOffice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please click on get current location button first')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

      // Format times correctly for API
  final startTimeFormatted = _formatTimeForApi(_startTime);
  final endTimeFormatted = _formatTimeForApi(_endTime);

    try {
      final submission = {
        'submittedBy': _userId, // Get from auth provider
        'name': _nameController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'driveStartTime': startTimeFormatted,
        'driveEndTime': endTimeFormatted,
        'contactPerson': _contactController.text.isNotEmpty
            ? _contactController.text
            : null,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: json.encode(submission),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submitted for approval!')));
        Navigator.pop(context);
      } else {
        final errorData = json.decode(response.body);
        throw errorData['message'] ?? 
           errorData['title'] ?? 
           errorData['error'] ?? 
           response.body;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
          // Validate end time is after start time
        if (_endTime.hour < _startTime.hour || 
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('End time must be after start time')),
          );
        }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Masjid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Masjid Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Person (Optional)',
                ),
              ),

              SizedBox(height: 16),
              Text(
                'Juma Time:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Khutba: ${_startTime.format(context)}'),
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Namaz: ${_endTime.format(context)}'),
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.location_on),
                label: Text(
                  _currentPosition == null
                      ? 'Get Current Location'
                      : 'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                ),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOffice,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit for Approval'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
