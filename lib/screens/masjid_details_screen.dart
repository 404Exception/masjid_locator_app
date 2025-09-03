import 'package:flutter/material.dart';
import '../models/masjid_submission.dart';
import '../shared/map_utils.dart';
import '../shared/time_util.dart';

class MasjidDetailScreen extends StatelessWidget {
  final MasjidSubmission office;

  const MasjidDetailScreen({super.key, required this.office});

  
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
            _buildInfoRow('Juma Time', TimeUtils.formatFromString(office.driveStartTime)),
            //if (office.contactPerson != null) _buildInfoRow('Contact', office.contactPerson!),
            //if (office.specialInstructions != null) _buildInfoRow('Instructions', office.specialInstructions!),
            //if (office.distance != null) _buildInfoRow('Distance', '${office.distance!.toStringAsFixed(1)} km'),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => MapUtils.openMap(
                              office.latitude,
                              office.longitude,
                              label: office.name, // this will be used in Google Maps
                              context: context,   // pass context if you want snackbar on failure
                              ),
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