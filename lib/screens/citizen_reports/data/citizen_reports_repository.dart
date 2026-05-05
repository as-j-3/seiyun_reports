import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_service.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/models/citizen_report_model.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/models/report_statistics.dart';
import 'package:seiyun_reports_app/core/database/reports_local_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';

class CitizenReportsRepository {
  final CitizenReportsService _service;
  final NetworkInfo _networkInfo;
  final ReportsLocalService _localService = ReportsLocalService();

  // Constructor: نمرر السيرفس للمستودع (Dependency Injection)
  CitizenReportsRepository(this._service, this._networkInfo);

  // دالة جلب البيانات وتحويلها لموديلات
  Future<List<CitizenReportModel>> fetchReports() async {
    try {
      // 1. جلب البيانات من الكاش المحلي أولاً
      List<CitizenReportModel> cachedReports = await _localService.getLocalCitizenReports();

      // 2. محاولة الجلب من السيرفر وتحديث الكاش 
      if (cachedReports.isEmpty) {
        await _syncCitizenReportsWithServer(); // انتظار المزامنة في أول تشغيل
        cachedReports = await _localService.getLocalCitizenReports(); // إعادة الجلب
      } else {
        _syncCitizenReportsWithServer(); // مزامنة في الخلفية
      }

      return cachedReports;
    } catch (e) {
      print("خطأ في المستودع أثناء جلب البلاغات: $e");
      return [];
    }
  }

  // دالة خاصة للمزامنة
  Future<void> _syncCitizenReportsWithServer() async {
    if (!await _networkInfo.isConnected) return; // لا تعمل مزامنة إذا لم يكن هناك نت
    try {
      final response = await _service.getAllCitizenReports();
      if (response.data['status'] == 'success') {
        final List list = response.data['data'];
        List<CitizenReportModel> remoteReports = list.map((json) => CitizenReportModel.fromJson(json)).toList();
        
        // حفظ البلاغات الجديدة محلياً
        await _localService.saveCitizenReports(remoteReports);
      }
    } catch (e) {
      print("خطأ أثناء مزامنة بلاغات المواطنين: $e");
    }
  }

  // دالة تحديث اللايك في السيرفر والجهاز
  Future<bool> updateLike(int reportId, bool isLiked, int newLikesCount) async {
    try {
      // 1. تحديث السيرفر
      final response = await _service.incrementLike(reportId);
      
      // 2. تحديث قاعدة البيانات المحلية فوراً لضمان بقاء الحالة عند إعادة التشغيل
      await _localService.updateCitizenReportLike(reportId, isLiked, newLikesCount);
      
      return response.statusCode == 200;
    } catch (e) {
      print("خطأ في تحديث اللايك: $e");
      return false;
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
}
