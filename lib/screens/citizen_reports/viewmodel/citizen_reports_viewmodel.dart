import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/notification_service.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_repository.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/report_statistics.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/comment_model.dart';
import '../models/citizen_report_model.dart';

class CitizenReportsViewModel extends ChangeNotifier {
  final CitizenReportsRepository _repository;
  Timer? _autoRefreshTimer;

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
    loadDashboardData(); 
    _startAutoRefresh();
  }
  /// الإعجاب ببلاغ أو إلغاء الإعجاب به
  Future<void> toggleLike(CitizenReportModel report) async {
    _autoRefreshTimer?.cancel(); 

    final index = _reports.indexWhere((r) => r.id == report.id);
    if (index == -1) {
      _startAutoRefresh();
      return;
    }

    final wasLiked = report.isLiked;

    _reports[index] = _reports[index].copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked
          ? (_reports[index].likesCount - 1).clamp(0, 999999)
          : _reports[index].likesCount + 1,
    );
    notifyListeners();

    try {
      await _repository.toggleLike(report);
    } catch (e) {
      _reports[index] = _reports[index].copyWith(
        isLiked: wasLiked,
        likesCount: wasLiked
            ? _reports[index].likesCount + 1
            : (_reports[index].likesCount - 1).clamp(0, 999999),
      );
      notifyListeners();
    } finally {
      _startAutoRefresh(); 
    }
  }

  /// زيادة عدد المشاهدات للبلاغ المحدد
  Future<void> incrementReportView(CitizenReportModel report) async {
    _autoRefreshTimer?.cancel();

    final index = _reports.indexWhere((r) => r.id == report.id);
    if (index == -1) {
      _startAutoRefresh();
      return;
    }

    final int newViewsCount = _reports[index].viewsCount + 1;
    _reports[index] = _reports[index].copyWith(viewsCount: newViewsCount);
    notifyListeners();

    try {
      await _repository.addView(report.id, newViewsCount);
    } catch (e) {
    } finally {
      _startAutoRefresh();
    }
  }
  /// بدء مؤقت التحديث التلقائي للبيانات
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadDashboardData(showLoading: false);
    });
  }

  /// تحميل بيانات البلاغات والإحصائيات من الخادم
  Future<void> loadDashboardData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final oldStatuses = {for (var r in _reports) r.id: r.status};

      _reports = await _repository.fetchReports();
      _stats = await _repository.getReportStats();

      if (oldStatuses.isNotEmpty) {
        for (final report in _reports) {
          final old = oldStatuses[report.id];
          if (old != null && old != report.status) {
            await NotificationService.showStatusChangedNotification(
              reportTitle: report.title,
              oldStatus: old,
              newStatus: report.status,
            );
          }
        }
      }
    } catch (e) {
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }


  /// تعيين نص البحث لتصفية البلاغات
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

  /// إضافة تعليق جديد على بلاغ محدد
  Future<bool> addComment(int reportId, String commentText) async {
    if (commentText.trim().isEmpty) return false;
    try {
      final success = await _repository.addComment(
        reportId,
        commentText.trim(),
      );
      if (success) {
        final index = _reports.indexWhere((r) => r.id == reportId);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(
            commentsCount: _reports[index].commentsCount + 1,
          );
          fetchComments(reportId);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// جلب التعليقات الخاصة ببلاغ محدد
  Future<void> fetchComments(int reportId) async {
    _comments = []; 
    notifyListeners();
    try {
      _comments = await _repository.fetchComments(reportId);
      notifyListeners();
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
