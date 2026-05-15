import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/notification_service.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_repository.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/report_statistics.dart';
import '../models/citizen_report_model.dart';

class CitizenReportsViewModel extends ChangeNotifier {
  final CitizenReportsRepository _repository;

  List<CitizenReportModel> _reports = [];
  List<CitizenReportModel> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ReportStatistics? _stats;
  ReportStatistics? get stats => _stats;

  CitizenReportsViewModel(this._repository) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // حفظ نسخة من الحالات القديمة قبل تحديث البيانات
      final Map<int, String> oldStatuses = {
        for (final r in _reports) r.id: r.status,
      };

      // جلب البيانات الجديدة من السيرفر
      _reports = await _repository.fetchReports();
      _stats = await _repository.getReportStats();

      // ── كشف تغيير الحالة وإطلاق إشعار فوري ──────────────────────────────────
      if (oldStatuses.isNotEmpty) {
        for (final report in _reports) {
          final old = oldStatuses[report.id];
          if (old != null && old != report.status) {
            // الحالة تغيرت → أرسل إشعاراً فورياً
            await NotificationService.showStatusChangedNotification(
              reportTitle: report.title,
              oldStatus: old,
              newStatus: report.status,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("❌ فشل الجلب: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(int reportId) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final report = _reports[index];
      final oldStatus = report.isLiked;
      final newStatus = !oldStatus;
      final newLikesCount =
          oldStatus ? report.likesCount - 1 : report.likesCount + 1;

      _reports[index] = report.copyWith(
        isLiked: newStatus,
        likesCount: newLikesCount,
      );
      notifyListeners();

      // إرسال التحديث للسيرفر وللجهاز (التخزين المحلي)
      bool success = await _repository.updateLike(
        reportId,
        newStatus,
        newLikesCount,
      );

      // لو فشل التحديث، نرجع الحالة كما كانت
      if (!success) {
        _reports[index] = report.copyWith(
          isLiked: oldStatus,
          likesCount: report.likesCount,
        );
        notifyListeners();
      }
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<CitizenReportModel> get filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports
        .where(
          (r) =>
              r.title.contains(_searchQuery) ||
              r.description.contains(_searchQuery),
        )
        .toList();
  }

  // هنا يقرأ البيانات من مودل الاحصائيات، مالم يجدها يحسبها
  int get totalReports => _stats?.total ?? _reports.length;
  int get resolvedReports =>
      _stats?.resolved ?? _reports.where((r) => r.status == 'تم الحل').length;
  int get activeReports =>
      _stats?.active ?? _reports.where((r) => r.status != 'تم الحل').length;
  String get resolutionRate {
    if (_stats != null) return _stats!.resolutionRate;
    if (_reports.isEmpty) return "0%";
    double calculatedRate = (resolvedReports / totalReports) * 100;
    return "${calculatedRate.toStringAsFixed(0)}%";
  }
}
