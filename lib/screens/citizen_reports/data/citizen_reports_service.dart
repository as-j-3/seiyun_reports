import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class CitizenReportsService {
  final ApiService _apiService;
  CitizenReportsService(this._apiService);

  /// جلب كافة بلاغات المواطنين من الخادم
  Future<Response> getAllCitizenReports() async {
    try {
      final response = await _apiService.get('ShowAllReports');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// زيادة عدد الإعجابات لبلاغ معين
  Future<Response> incrementLike(int reportId) async {
    try {
      return await _apiService.get('reports/$reportId/increment-likes');
    } catch (e) {
      rethrow;
    }
  }

  /// إلغاء الإعجاب لبلاغ معين
  Future<Response> decrementLike(int reportId) async {
    try {
      return await _apiService.get('reports/$reportId/decrement-likes');
    } catch (e) {
      rethrow;
    }
  }

  /// زيادة عدد المشاهدات لبلاغ معين
  Future<Response> incrementView(int reportId) async {
    try {
      return await _apiService.post('reports/$reportId/increment-views');
    } catch (e) {
      rethrow;
    }
  }

  /// جلب إحصائيات البلاغات من الخادم
  Future<Response> getStatistics() async {
    return await _apiService.get('reports/statistics');
  }

  /// إضافة تعليق جديد على بلاغ معين
  Future<Response> addComment({
    required int reportId,
    required String commentText,
  }) async {
    try {
      return await _apiService.post(
        'comments/create',
        data: {
          'report_id': reportId,
          'comment_text': commentText,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// جلب التعليقات الخاصة ببلاغ معين (GET)
  Future<Response> getComments(int reportId) async {
    try {
      return await _apiService.get('reports/$reportId/comments');
    } catch (e) {
      rethrow;
    }
  }


}