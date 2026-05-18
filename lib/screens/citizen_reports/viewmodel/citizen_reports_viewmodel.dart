import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_repository.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/report_statistics.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/comment_model.dart';
import '../models/citizen_report_model.dart';

class CitizenReportsViewModel extends ChangeNotifier {
  final CitizenReportsRepository _repository;

  List<CitizenReportModel> _reports = [];
  List<CitizenReportModel> get reports => _reports;

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  ReportStatistics? _stats;
  ReportStatistics? get stats => _stats;

  CitizenReportsViewModel(this._repository) {
    loadDashboardData(); // استدعاء لدالة الجلب  عند التشغيل
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. جلب البلاغات والاحصائيات من السيرفر
      _reports = await _repository.fetchReports();
      _stats = await _repository.getReportStats();
      
      // 2. زيادة المشاهدات لكل البلاغات التي ظهرت للمستخدم في الخلفية
      _incrementViewsForLoadedReports();
          } catch (e) {
      print("❌ فشل الجلب: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _incrementViewsForLoadedReports() {
    for (int i = 0; i < _reports.length; i++) {
      final report = _reports[i];
      // تحديث السيرفر وقاعدة البيانات المحلية في الخلفية
      _repository.addView(report.id, report.viewsCount);
      
      // تحديث القائمة الحالية في الذاكرة ليظهر التغيير فوراً في الواجهة
      _reports[i] = report.copyWith(viewsCount: report.viewsCount + 1);
    }
    notifyListeners();
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
              r.description.contains(_searchQuery) ||
              r.description.contains(_searchQuery),
        )
        .toList();
  }

  //هنا يقرا البيانات من مودل الاحصائيات مالم يجدها هو يحسبها
  int get totalReports => _stats?.total ?? _reports.length;
  int get resolvedReports =>
      _stats?.resolved ?? _reports.where((r) => r.status == 'تم الحل').length;
  int get activeReports =>
      _stats?.active ?? _reports.where((r) => r.status != 'تم الحل').length;
  String get resolutionRate {
    if (_stats != null) {
      return _stats!.resolutionRate;
    }

    if (_reports.isEmpty) return "0%";
    double calculatedRate = (resolvedReports / totalReports) * 100;
    return "${calculatedRate.toStringAsFixed(0)}%";
  }

  Future<bool> addComment(int reportId, String commentText) async {
    if (commentText.trim().isEmpty) return false;
    try {
      final success = await _repository.addComment(reportId, commentText.trim());
      if (success) {
        // تحديث عداد التعليقات فوراً في الواجهة
        final index = _reports.indexWhere((r) => r.id == reportId);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(
            commentsCount: _reports[index].commentsCount + 1,
          );
          // يمكننا إعادة جلب التعليقات لتظهر فوراً
          fetchComments(reportId);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      print("خطأ في ViewModel عند إضافة تعليق: $e");
      return false;
    }
  }

  Future<void> fetchComments(int reportId) async {
    _comments = []; // تصفير القائمة لمنع ظهور تعليقات البلاغ السابق
    notifyListeners();
    try {
      _comments = await _repository.fetchComments(reportId);
      notifyListeners();
    } catch (e) {
      print("خطأ في جلب التعليقات في ViewModel: $e");
    }
  }
}
