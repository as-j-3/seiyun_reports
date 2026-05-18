class CitizenReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final int viewsCount;
  final int commentsCount;
  final String report_image; 
  final String? imageAfterProcessing;
  final String created_at;
  final String user_name; 
  final String user_profile; 
  final double latitude;
  final double longitude;

  CitizenReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.viewsCount,
    required this.commentsCount,
    required this.report_image,
    this.imageAfterProcessing,
    required this.created_at,
    required this.user_name,
    required this.user_profile,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory CitizenReportModel.fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: json['id'],
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      status: json['status'] ?? "",
      viewsCount: json['views'] ?? 0,
      commentsCount: json['comments'] ?? 0,
      report_image: json['report_image'] ?? "",
      imageAfterProcessing: json['Image_after_processing'],
      created_at: json['created_at'] ?? "",
      user_name: json['user_name'] ?? "مواطن",
      user_profile: json['user_profile'] ?? "",
      latitude: json['lat'] != null ? double.parse(json['lat'].toString()) : 0.0,
      longitude: json['lng'] != null ? double.parse(json['lng'].toString()) : 0.0,
    );
  }
   // يمكن اغيرها في حال استخدمت sqlite  خلوها مؤقتا 
  // نحتاج هذه الدالة لتحديث الحالة في الـ ViewModel بشكل مرن
  CitizenReportModel copyWith({
    int? commentsCount,
    int? viewsCount,
    String? status,
  }) {
    return CitizenReportModel(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      report_image: report_image,
      imageAfterProcessing: imageAfterProcessing,
      created_at: created_at,
      user_name: user_name,
      user_profile: user_profile,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,
      'report_image': report_image,
      'imageAfterProcessing': imageAfterProcessing,
      'created_at': created_at,
      'user_name': user_name,
      'user_profile': user_profile,
    };
  }

  factory CitizenReportModel.fromMap(Map<String, dynamic> map) {
    return CitizenReportModel(
      id: map['id'],
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      status: map['status'] ?? "",
      viewsCount: map['viewsCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      report_image: map['report_image'] ?? "",
      imageAfterProcessing: map['imageAfterProcessing'],
      created_at: map['created_at'] ?? "",
      user_name: map['user_name'] ?? "مواطن",
      user_profile: map['user_profile'] ?? "",
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }
}