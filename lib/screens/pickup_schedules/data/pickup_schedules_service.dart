
import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class PickupSchedulesService {
  final ApiService _apiService;

  PickupSchedulesService(this._apiService);

  /// جلب الحاويات والجداول بناءً على الموقع (POST)
  Future<Response> getAreaSchedules({double? lat, double? lng}) async {
    try {
      return await _apiService.post(
        'getMyAreaSchedules',
        data: {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
