class PickupScheduleModel {
  final String id;
  final String day;
  final String date;
  final String startTime;
  final String endTime;
  final List<String> locations;
  final bool isToday;
  final bool isTomorrow;

  PickupScheduleModel({
    required this.id,
    required this.day,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.locations,
    this.isToday = false,
    this.isTomorrow = false,
  });

  factory PickupScheduleModel.fromJson(Map<String, dynamic> json) {
    return PickupScheduleModel(
      id: json['id']?.toString() ?? '',
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      locations: List<String>.from(json['locations'] ?? []),
      isToday: json['is_today'] ?? false,
      isTomorrow: json['is_tomorrow'] ?? false,
    );
  }
}

class NearbyContainerModel {
  final String id;
  final String name;
  final String address;
  final double distance; // in meters
  final String status; // 'empty', 'half', 'full'
  final double latitude;
  final double longitude;

  NearbyContainerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.status,
    this.latitude = 15.9429,
    this.longitude = 48.7844,
  });
}
