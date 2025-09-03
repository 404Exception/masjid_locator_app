import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  static Future<void> openMap(
    double latitude,
    double longitude, {
    required String label,
    BuildContext? context,
  }) async {
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$label');

    final geoUrl = Uri.parse('geo:$latitude,$longitude?q=$label');
    final httpUrl = Uri.parse('http://maps.google.com/?q=$latitude,$longitude($label)');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(httpUrl)) {
        await launchUrl(httpUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open maps. Please install Google Maps.'),
            action: SnackBarAction(
              label: 'Install',
              onPressed: _openPlayStore,
            ),
          ),
        );
      }
    }
  }

  static void _openPlayStore() {
    final playStoreUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.google.android.apps.maps');
    launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
  }
}
