import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/masjid_submission.dart';

class MasjidDetailScreen extends StatelessWidget {
  final MasjidSubmission office;

  MasjidDetailScreen({required this.office});

  Future<void> _openMap() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${office.latitude},${office.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(office.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              office.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              office.address,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            _buildInfoRow('City', office.city),
            _buildInfoRow('Juma Time', office.driveStartTime),
            //if (office.contactPerson != null) _buildInfoRow('Contact', office.contactPerson!),
            //if (office.specialInstructions != null) _buildInfoRow('Instructions', office.specialInstructions!),
            //if (office.distance != null) _buildInfoRow('Distance', '${office.distance!.toStringAsFixed(1)} km'),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openMap,
              icon: Icon(Icons.map),
              label: Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}