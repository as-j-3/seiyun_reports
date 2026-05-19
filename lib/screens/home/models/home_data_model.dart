
class HomeDataModel {
  final String userName;
  final int reportActive;
  final int reportSolved;
  final NextCollectionModel nextCollection;
  final List<RecentReportModel> reports;

  HomeDataModel({
    required this.userName,
    required this.reportActive,
    required this.reportSolved,
    required this.nextCollection,
    required this.reports,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    var reportsList = json['report'] as List? ?? [];
    return HomeDataModel(
      userName: json['user_name'] ?? '',
      reportActive: json['report_active'] ?? 0,
      reportSolved: json['report_solved'] ?? 0,
      nextCollection: NextCollectionModel.fromJson(json['next_collection'] ?? {}),
      reports: reportsList.map((i) => RecentReportModel.fromJson(i)).toList(),
    );
  }
}

class NextCollectionModel {
  final String status;
  final String timing;

  NextCollectionModel({required this.status, required this.timing});

  factory NextCollectionModel.fromJson(Map<String, dynamic> json) {
    return NextCollectionModel(
      status: json['status'] ?? '',
      timing: json['timing'] ?? '',
    );
  }
}

class RecentReportModel {
  final int id;
  final String title;
  final String status;
  final String createdAt;

  RecentReportModel({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory RecentReportModel.fromJson(Map<String, dynamic> json) {
    return RecentReportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
