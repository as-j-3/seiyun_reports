import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class ReportService {
  final ApiService _apiService;
  ReportService(this._apiService);

  // إرسال بلاغ جديد (POST)
  Future<Response> createReport(FormData formData) async {
    return await _apiService.post(
      'reports/create', 
      data: formData,
      
    );
  }

  // جلب بلاغاتي 
  Future<Response> getMyReports( ) async {
    return await _apiService.post( 
      'ShowMyReport', 
    );
  }
}