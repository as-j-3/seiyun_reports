import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_service.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/citizen_report_model.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/report_statistics.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/comment_model.dart';
import 'package:seiyun_reports_app/core/database/reports_local_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';

class CitizenReportsRepository {
  final CitizenReportsService _service;
  final NetworkInfo _networkInfo;
  final ReportsLocalService _localService = ReportsLocalService();

  CitizenReportsRepository(this._service, this._networkInfo);

  /// جلب بلاغات المواطنين من الخادم أو من قاعدة البيانات المحلية في حال عدم وجود اتصال بالإنترنت.
  Future<List<CitizenReportModel>> fetchReports() async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _service.getAllCitizenReports();
        if (response.data['status'] == 'success' || response.statusCode == 201 || response.statusCode == 200) {
          final List list = response.data['data'];

          List<CitizenReportModel> remoteReports = list.map((json) {
            return CitizenReportModel.fromJson(json);
          }).toList();

          final localReports = await _localService.getLocalCitizenReports();
          final localDataMap = {for (var r in localReports) r.id: r};

          remoteReports = remoteReports.map((remoteReport) {
            final localReport = localDataMap[remoteReport.id];
            if (localReport != null) {
              return remoteReport.copyWith(
                isLiked: localReport.isLiked,
                likesCount: localReport.likesCount,
                viewsCount: remoteReport.viewsCount > localReport.viewsCount
                    ? remoteReport.viewsCount
                    : localReport.viewsCount,
              );
            }
            return remoteReport;
          }).toList();

          await _localService.saveCitizenReports(remoteReports);
          return remoteReports;
        }
      } catch (e) {
      }
    }

    return await _localService.getLocalCitizenReports();
  }

  /// جلب إحصائيات البلاغات من الخادم.
  Future<ReportStatistics?> getReportStats() async {
  if (!await _networkInfo.isConnected) return null; 
  try {
    final response = await _service.getStatistics();
    if (response.data['status'] == 'success') {
      return ReportStatistics.fromJson(response.data['data']);
    }
  } catch (e) {
  }
  return null;
}

  /// إضافة تعليق جديد على بلاغ معين.
  Future<bool> addComment(int reportId, String commentText) async {
    if (!await _networkInfo.isConnected) return false;
    try {
      final response = await _service.addComment(
        reportId: reportId,
        commentText: commentText,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// جلب جميع التعليقات الخاصة ببلاغ معين.
  Future<List<CommentModel>> fetchComments(int reportId) async {
    if (!await _networkInfo.isConnected) return [];
    try {
      final response = await _service.getComments(reportId);
      if (response.data['status'] == 'success') {
        final List list = response.data['data'];
        return list.map((json) => CommentModel.fromJson(json)).toList();
      }
    } catch (e) {
    }
    return [];
  }

  /// تبديل حالة الإعجاب لبلاغ معين محلياً وعبر الخادم.
  Future<void> toggleLike(CitizenReportModel report) async {
    final bool newIsLiked = !report.isLiked;
    final int newLikesCount = newIsLiked ? report.likesCount + 1 : (report.likesCount - 1).clamp(0, 999999);

    await _localService.updateCitizenReportLikeLocal(report.id, newIsLiked, newLikesCount);

    if (!await _networkInfo.isConnected) return;
    try {
      if (report.isLiked) {
        await _service.decrementLike(report.id);
      } else {
        await _service.incrementLike(report.id);
      }
    } catch (e) {
      await _localService.updateCitizenReportLikeLocal(report.id, report.isLiked, report.likesCount);
      rethrow;
    }
  }

  /// زيادة عدد المشاهدات لبلاغ معين محلياً وعبر الخادم.
  Future<void> addView(int reportId, int newViewsCount) async {
    try {
      await _localService.incrementCitizenReportView(reportId, newViewsCount);

      if (await _networkInfo.isConnected) {
        await _service.incrementView(reportId);
      }
    } catch (e) {
    }
  }
}
