import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class CitizenReportsService {
  final ApiService _apiService;
  CitizenReportsService(this._apiService);

  Future<Response> getAllCitizenReports() async {
    try {
      final response = await _apiService.get('ShowAllReports');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> incrementView(int reportId) async {
    try {
      return await _apiService.post('reports/$reportId/increment-views');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getStatistics() async {
    return await _apiService.get('reports/statistics');
  }

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