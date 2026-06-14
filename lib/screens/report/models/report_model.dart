import 'package:flutter/foundation.dart';

class ReportModel {
  final int id;
  final int citizenId;
  final String title;
  final String? areaId;
  final String? areaName;
  final String? squareName;
  final String description;
  final String image;
  final String status;
  final String reportType;
  final String lat;
  final String lng;
  final String createdAt;

  ReportModel({
    required this.id,
    required this.citizenId,
    required this.title,
    this.areaId,
    this.areaName,
    this.squareName,
    required this.description,
    required this.image,
    required this.status,
    required this.reportType,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReportModel(
        id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
        citizenId:
            json['citizen_id'] != null
                ? int.parse(json['citizen_id'].toString())
                : 0,
        title: json['title']?.toString() ?? 'بلاغ بدون عنوان',
        areaId:
            json['area_id'] != null && json['area_id'].toString() != '0'
                ? json['area_id'].toString()
                : null,
        areaName: json['area_name']?.toString(),
        squareName: json['square_name']?.toString(),
        description: json['description']?.toString() ?? '',
        image:
            json['image'] != null && json['image'].toString().isNotEmpty
                ? json['image'].toString()
                : "https://via.placeholder.com/150",
        status: json['status']?.toString() ?? 'قيد الإنتظار',
        reportType: (json['report_type'] ?? json['type'] ?? 'رفع').toString(),
        lat: json['lat']?.toString() ?? '0.0',
        lng: json['lng']?.toString() ?? '0.0',
        createdAt: json['created_at']?.toString() ?? '',
      );
    } catch (e) {
      return ReportModel(
        id: 0,
        citizenId: 0,
        title: "خطأ في قراءة البيانات",
        description: "JSON content: $json",
        image: "",
        status: "Error",
        reportType: "",
        lat: "0.0",
        lng: "0.0",
        createdAt: "",
      );
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'report_type': reportType,
      'lat': lat,
      'lng': lng,
      'image': image,
      'area_id': areaId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'citizen_id': citizenId,
      'title': title,
      'area_id': areaId,
      'area_name': areaName,
      'square_name': squareName,
      'description': description,
      'image': image,
      'status': status,
      'report_type': reportType,
      'lat': lat,
      'lng': lng,
      'created_at': createdAt,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? 0,
      citizenId: map['citizen_id'] ?? 0,
      title: map['title'] ?? 'بدون عنوان',
      areaId: map['area_id']?.toString(),
      areaName: map['area_name'],
      squareName: map['square_name'],
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      status: map['status'] ?? 'قيد الإنتظار',
      reportType: map['report_type'] ?? 'رفع',
      lat: map['lat'] ?? '0.0',
      lng: map['lng'] ?? '0.0',
      createdAt: map['created_at'] ?? '',
    );
  }
}
