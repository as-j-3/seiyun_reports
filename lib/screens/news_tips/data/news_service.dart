import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class Newsservice {
  final ApiService _apiService;
  Newsservice(this._apiService);

  /// جلب النصائح البيئية من الخادم
  Future<Response> getTips() async {
    return await _apiService.get('tipCitizen_tips'); 
  }

  /// جلب الأخبار من الخادم
  Future<Response> getNews() async {
    return await _apiService.get('tipCitizen_news'); 
  }}