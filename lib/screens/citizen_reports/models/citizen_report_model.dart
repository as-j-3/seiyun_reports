class CitizenReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final int viewsCount;
  final int commentsCount;
  final int likesCount;
  final bool isLiked;
  final String report_image;
  final String? imageAfterProcessing;
  final String created_at;
  final String user_name;
  final String user_profile;

  CitizenReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.viewsCount,
    required this.commentsCount,
    this.likesCount = 0,
    this.isLiked = false,
    required this.report_image,
    this.imageAfterProcessing,
    required this.created_at,
    required this.user_name,
    required this.user_profile,
  });

  factory CitizenReportModel.fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      status: json['status'] ?? "",
      viewsCount: json['views'] != null ? int.tryParse(json['views'].toString()) ?? 0 : 0,
      commentsCount: json['comments'] != null ? int.tryParse(json['comments'].toString()) ?? 0 : 0,
      likesCount: json['likes'] != null ? int.tryParse(json['likes'].toString()) ?? 0 : 0,
      isLiked: json['is_liked'] ?? false,
      report_image: json['report_image'] ?? "",
      imageAfterProcessing: json['Image_after_processing'],
      created_at: json['created_at'] ?? "",
      user_name: json['user_name'] ?? "مواطن",
      user_profile: json['user_profile'] ?? "",
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
      'likesCount': likesCount,
      'isLiked': isLiked ? 1 : 0,
      'report_image': report_image,
      'imageAfterProcessing': imageAfterProcessing,
      'created_at': created_at,
      'user_name': user_name,
      'user_profile': user_profile,
    };
  }

  factory CitizenReportModel.fromMap(Map<String, dynamic> map) {
    return CitizenReportModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      status: map['status'] ?? "",
      viewsCount: map['viewsCount'] != null ? int.tryParse(map['viewsCount'].toString()) ?? 0 : 0,
      commentsCount: map['commentsCount'] != null ? int.tryParse(map['commentsCount'].toString()) ?? 0 : 0,
      likesCount: map['likesCount'] != null ? int.tryParse(map['likesCount'].toString()) ?? 0 : 0,
      isLiked: map['isLiked'] == 1 || map['isLiked'] == true,
      report_image: map['report_image'] ?? "",
      imageAfterProcessing: map['imageAfterProcessing'],
      created_at: map['created_at'] ?? "",
      user_name: map['user_name'] ?? "مواطن",
      user_profile: map['user_profile'] ?? "",
    );
  }

  CitizenReportModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    int? viewsCount,
    int? commentsCount,
    int? likesCount,
    bool? isLiked,
    String? report_image,
    String? imageAfterProcessing,
    String? created_at,
    String? user_name,
    String? user_profile,
  }) {
    return CitizenReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      report_image: report_image ?? this.report_image,
      imageAfterProcessing: imageAfterProcessing ?? this.imageAfterProcessing,
      created_at: created_at ?? this.created_at,
      user_name: user_name ?? this.user_name,
      user_profile: user_profile ?? this.user_profile,
    );
  }
}