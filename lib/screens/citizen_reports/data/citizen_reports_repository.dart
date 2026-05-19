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

  // Constructor: نمرر السيرفس للمستودع (Dependency Injection)
  CitizenReportsRepository(this._service, this._networkInfo);

  // جلب كافة البلاغات (بنفس أسلوب AssignmentRepository)
  Future<List<CitizenReportModel>> fetchReports() async {
    // 1. إذا كان هناك إنترنت، نجلب من السيرفر ونحدث المحلي فوراً
    if (await _networkInfo.isConnected) {
      try {
        final response = await _service.getAllCitizenReports();
        if (response.data['status'] == 'success') {
          final List list = response.data['data'];
          
          List<CitizenReportModel> remoteReports = list.map((json) {
            return CitizenReportModel.fromJson(json);
          }).toList();

          // حفظ في SQLite
          await _localService.saveCitizenReports(remoteReports);
          return remoteReports;
        }
      } catch (e) {
        print("خطأ في الجلب من السيرفر، العودة للمحلي: $e");
      }
    }

    // 2. إذا لم يتوفر إنترنت أو فشل الطلب، نجلب من المحلي
    return await _localService.getLocalCitizenReports();
  }


  // دالة زيادة المشاهدات
  Future<void> addView(int reportId, int currentViews) async {
    try {
      // 1. تحديث السيرفر
      await _service.incrementView(reportId);
      // 2. تحديث المحلي
      await _localService.incrementCitizenReportView(reportId, currentViews);
    } catch (e) {
      print("خطأ في زيادة المشاهدات: $e");
    }
  }
  //دالة جلب الاحصائيات 
  Future<ReportStatistics?> getReportStats() async {
  if (!await _networkInfo.isConnected) return null; // لا تنتظر طلب السيرفر إذا لم يكن هناك إنترنت
  try {
    final response = await _service.getStatistics();
    if (response.data['status'] == 'success') {
      return ReportStatistics.fromJson(response.data['data']);
    }
  } catch (e) {
    print("Error fetching stats: $e");
  }
  return null;
}

  // دالة إضافة تعليق على بلاغ
  Future<bool> addComment(int reportId, String commentText) async {
    if (!await _networkInfo.isConnected) return false;
    try {
      final response = await _service.addComment(
        reportId: reportId,
        commentText: commentText,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("خطأ في إرسال التعليق: $e");
      return false;
    }
  }

  // دالة جلب التعليقات الخاصة ببلاغ
  Future<List<CommentModel>> fetchComments(int reportId) async {
    if (!await _networkInfo.isConnected) return [];
    try {
      final response = await _service.getComments(reportId);
      if (response.data['status'] == 'success') {
        final List list = response.data['data'];
        return list.map((json) => CommentModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("خطأ في جلب التعليقات: $e");
    }
    return [];
  }
}
