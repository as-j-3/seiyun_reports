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
  final String locationName;
  final String nameStreet;
  final String classification;
  final String distance;
  final String walkingTime;
  final String areaName;
  final String period;
  final String areaStartTime;
  final String areaEndTime;
  final String statusText;
  final String collectionDay;
  final double latitude;
  final double longitude;

  NearbyContainerModel({
    required this.id,
    required this.locationName,
    required this.nameStreet,
    required this.classification,
    required this.distance,
    required this.walkingTime,
    required this.areaName,
    required this.period,
    required this.areaStartTime,
    required this.areaEndTime,
    required this.statusText,
    required this.collectionDay,
    this.latitude = 15.9429,
    this.longitude = 48.7844,
  });

  factory NearbyContainerModel.fromJson(Map<String, dynamic> json) {
    return NearbyContainerModel(
      id: json['id']?.toString() ?? '',
      locationName: json['location_name'] ?? '',
      nameStreet: json['name_street'] ?? '',
      classification: json['classification'] ?? '',
      distance: json['distance'] ?? '',
      walkingTime: json['walking_time'] ?? '',
      areaName: json['area_name'] ?? '',
      period: json['period'] ?? '',
      areaStartTime: json['area_start_time'] ?? '',
      areaEndTime: json['area_end_time'] ?? '',
      statusText: json['status_text'] ?? '',
      collectionDay: json['schedule']?['collection_day'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 15.9429,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 48.7844,
    );
  }
}

