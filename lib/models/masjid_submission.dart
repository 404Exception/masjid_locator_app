class MasjidSubmission {
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String driveStartTime;
  final String driveEndTime;

  MasjidSubmission({
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.driveStartTime,
    required this.driveEndTime,
  });

  // factory MasjidSubmission.fromJson(Map<String, dynamic> json) {
  //   return MasjidSubmission(
  //     name: json['name'],
  //     address: json['address'],
  //     city: json['city'],
  //     latitude: json['latitude']?.toDouble() ?? 0.0,
  //     longitude: json['longitude']?.toDouble() ?? 0.0,
  //     driveStartTime: json['driveStartTime'],
  //     driveEndTime: json['driveEndTime']
  //   );
  // }

  factory MasjidSubmission.fromJson(Map<String, dynamic> json) {
  try {
    return MasjidSubmission(
      //id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      driveStartTime: json['driveStartTime']?.toString() ?? '',
      driveEndTime: json['driveEndTime']?.toString() ?? '',
      //contactPerson: json['contactPerson']?.toString(),
      //specialInstructions: json['specialInstructions']?.toString(),
      //distance: _parseDouble(json['distance']),
    );
  } catch (e) {
    print('Error parsing office: $e');
    print('JSON data: $json');
    rethrow;
  }
}

static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
}