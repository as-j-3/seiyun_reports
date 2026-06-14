import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class ReportService {
  final ApiService _apiService;
  ReportService(this._apiService);

  /// إرسال بلاغ جديد إلى الخادم عبر FormData
  Future<Response> createReport(FormData formData) async {
    return await _apiService.post(
      'reports/create', 
      data: formData,
      
    );
  }

  /// جلب بلاغات المستخدم الحالي من الخادم
  Future<Response> getMyReports( ) async {
    return await _apiService.post( 
      'ShowMyReport', 
    );
  }
}