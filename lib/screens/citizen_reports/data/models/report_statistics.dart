class ReportStatistics {
  final int total;
  final int active;
  final int resolved;
  final String resolutionRate;

  ReportStatistics({
    required this.total,
    required this.active,
    required this.resolved,
    required this.resolutionRate,
  });

  factory ReportStatistics.fromJson(Map<String, dynamic> json) {
    return ReportStatistics(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      resolved: json['resolved'] ?? 0,
      resolutionRate: json['resolution_rate'] ?? "0%",
    );
  }
}