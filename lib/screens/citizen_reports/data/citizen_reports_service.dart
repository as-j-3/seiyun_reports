
import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class CitizenReportsService {
  final ApiService _apiService ;
  CitizenReportsService(this._apiService);


  Future<Response> getAllCitizenReports() async {
    try {
      final response = await _apiService.get('ShowAllReports');
      return response;
    } catch (e) {
      rethrow; 
    }
  }

  Future<Response> incrementLike(int reportId) async {
    try {
      return await _apiService.post('reports/$reportId/increment-likes');
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
  return await _apiService.get('reports/statistics'); // تأكدي من المسار في البوست مان
}
}