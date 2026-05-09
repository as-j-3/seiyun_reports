class CitizenReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final String report_image; 
  final String? imageAfterProcessing;
  final String created_at;
  final String user_name; 
  final String user_profile; 
  final double latitude;
  final double longitude;
  bool isLiked; // سنستخدمها للتعامل مع زر اللايك محلياً

  CitizenReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.likesCount,
    required this.viewsCount,
    required this.commentsCount,
    required this.report_image,
    this.imageAfterProcessing,
    required this.created_at,
    required this.user_name,
    required this.user_profile,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isLiked = false,
  });

  factory CitizenReportModel.fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: json['id'],
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      status: json['status'] ?? "",
      likesCount: json['likes'] ?? 0,
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
  // نحتاج هذه الدالة لتحديث حالة اللايك في الـ ViewModel
  CitizenReportModel copyWith({bool? isLiked, int? likesCount}) {
    return CitizenReportModel(
      id: id,
      title: title,
      description: description,
      status: status,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount,
      commentsCount: commentsCount,
      report_image: report_image,
      imageAfterProcessing: imageAfterProcessing,
      created_at: created_at,
      user_name: user_name,
      user_profile: user_profile,
      latitude: latitude,
      longitude: longitude,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,
      'report_image': report_image,
      'imageAfterProcessing': imageAfterProcessing,
      'created_at': created_at,
      'user_name': user_name,
      'user_profile': user_profile,
      'isLiked': isLiked ? 1 : 0,
    };
  }

  factory CitizenReportModel.fromMap(Map<String, dynamic> map) {
    return CitizenReportModel(
      id: map['id'],
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      status: map['status'] ?? "",
      likesCount: map['likesCount'] ?? 0,
      viewsCount: map['viewsCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      report_image: map['report_image'] ?? "",
      imageAfterProcessing: map['imageAfterProcessing'],
      created_at: map['created_at'] ?? "",
      user_name: map['user_name'] ?? "مواطن",
      user_profile: map['user_profile'] ?? "",
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      isLiked: map['isLiked'] == 1,
    );
  }
}