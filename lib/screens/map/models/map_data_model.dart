
class MapDataModel {
  final List<MapReportModel> reports;
  final List<MapContainerModel> containers;

  MapDataModel({required this.reports, required this.containers});

  factory MapDataModel.fromJson(Map<String, dynamic> json) {
    return MapDataModel(
      reports: (json['reports'] as List)
          .map((i) => MapReportModel.fromJson(i))
          .toList(),
      containers: (json['containers'] as List)
          .map((i) => MapContainerModel.fromJson(i))
          .toList(),
    );
  }
}

class MapReportModel {
  final int id;
  final String status;
  final double lat;
  final double lng;

  MapReportModel({
    required this.id,
    required this.status,
    required this.lat,
    required this.lng,
  });

  factory MapReportModel.fromJson(Map<String, dynamic> json) {
    return MapReportModel(
      id: json['id'],
      status: json['status'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
    );
  }
}

class MapContainerModel {
  final int id;
  final String locationName;
  final double lat;
  final double lng;
  final String type;

  MapContainerModel({
    required this.id,
    required this.locationName,
    required this.lat,
    required this.lng,
    required this.type,
  });

  factory MapContainerModel.fromJson(Map<String, dynamic> json) {
    return MapContainerModel(
      id: json['id'],
      locationName: json['location_name'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
      type: json['type'] ?? '',
    );
  }
}
