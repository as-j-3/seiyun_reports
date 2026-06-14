
class PickupScheduleModel {
  final int id;
  final String locationName;
  final String? nameStreet;
  final double latitude;
  final double longitude;
  final String distance;
  final String walkingTime;
  final String areaName;
  final String period;
  final String areaStartTime;
  final String areaEndTime;
  final String status;
  final String scheduleDays;

  bool get isToday => status == "الآن"; 
  bool get isTomorrow => false;
  String get day => scheduleDays;
  String get date => period; 
  String get startTime => areaStartTime;
  String get endTime => areaEndTime;
  List<String> get locations => [locationName, areaName];

  PickupScheduleModel({
    required this.id,
    required this.locationName,
    this.nameStreet,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.walkingTime,
    required this.areaName,
    required this.period,
    required this.areaStartTime,
    required this.areaEndTime,
    required this.status,
    required this.scheduleDays,
  });

  factory PickupScheduleModel.fromJson(Map<String, dynamic> json) {
    return PickupScheduleModel(
      id: json['id'],
      locationName: json['location_name'] ?? '',
      nameStreet: json['name_street'],
      latitude: double.tryParse(json['lat'].toString()) ?? 0.0,
      longitude: double.tryParse(json['lng'].toString()) ?? 0.0,
      distance: json['distance'] ?? '',
      walkingTime: json['walking_time'] ?? '',
      areaName: json['area_name'] ?? '',
      period: json['period'] ?? '',
      areaStartTime: json['area_start_time'] ?? '',
      areaEndTime: json['area_end_time'] ?? '',
      status: json['status'] ?? '',
      scheduleDays: json['schedule'] != null ? json['schedule']['days'] : '',
    );
  }
}
