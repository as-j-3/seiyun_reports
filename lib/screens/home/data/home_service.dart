
import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class HomeService {
  final ApiService _apiService;

  HomeService(this._apiService);

  /// جلب بيانات الصفحة الرئيسية (POST)
  Future<Response> getHomeData() async {
    try {
      return await _apiService.post('home');
    } catch (e) {
      rethrow;
    }
  }
}
