class ReportModel {
 // تعريف الحقول الي بتجي من قواعد البيانات 
  final int id;
  final int citizenId;
  final String title;
  final int? areaId;
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
    required this.description,
    required this.image,
    required this.status,
    required this.reportType,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });
  // تحويل من جيسون الى كائن 
  factory ReportModel.fromJson(Map<String, dynamic> json) {
   
    return ReportModel(
     // نحط قيم افتراضية تجنب للاخطاء 
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      citizenId: json['citizen_id'] ?? 0,
      title: json['title'] ?? 'بلاغ بدون عنوان',
      areaId: json['area_id']?? 0,
      description: json['description'] ?? '',
      image: json['image'] != null && json['image'].toString().isNotEmpty 
           ? json['image'].toString() 
           : "https://via.placeholder.com/150",
      status: json['status'] ?? 'قيد الانتظار',
      reportType: json['report_type'] ?? 'رفع',
      lat: json['lat']?.toString() ?? '0.0',
      lng: json['lng']?.toString() ?? '0.0',
      createdAt: json['created_at'] ?? '',
    );
  }
  // تحويل الكائن الى جيسون نحتاجه عند الارسال الى قاعدة البيانات 
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

// تحويل الكائن الى ماب بكامل الحقول للحفظ في قاعدة البيانات المحلية
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'citizen_id': citizenId,
    'title': title,
    'area_id': areaId,
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
    id: map['id'],
    citizenId: map['citizen_id'],
    title: map['title'],
    areaId: map['area_id'],
    description: map['description'],
    image: map['image'],
    status: map['status'],
    reportType: map['report_type'],
    lat: map['lat'],
    lng: map['lng'],
    createdAt: map['created_at'],
  );
}
}