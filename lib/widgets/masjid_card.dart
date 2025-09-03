import 'package:flutter/material.dart';
import '../models/masjid_submission.dart';
import '../shared/time_util.dart';

class MasjidCard extends StatelessWidget {
  final MasjidSubmission office;
  final VoidCallback onTap;

  MasjidCard({required this.office, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.business, size: 40, color: Colors.blue),
        title: Text(
          office.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text(
              'Juma - ${TimeUtils.formatFromString(office.driveStartTime)}',
              style: TextStyle(color: Colors.green),
            ),
            // if (office.distance != null)
            //   Text(
            //     '${office.distance!.toStringAsFixed(1)} km away',
            //     style: TextStyle(color: Colors.grey),
            //   ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}