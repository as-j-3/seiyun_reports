
import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class MapService {
  final ApiService _apiService;

  MapService(this._apiService);

  Future<Response> getMapData() async {
    try {
      return await _apiService.get('getMapData');
    } catch (e) {
      rethrow;
    }
  }
}
