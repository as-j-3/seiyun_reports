import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/view/models/confirmation_model.dart';

class AssignmentService {
  final ApiService _apiService;

  AssignmentService(this._apiService);

  /// جلب المهام الخاصة بالمشرف الميداني
  Future<Response> getSupervisorAssignments() async {
    try {
      // بناءً على الصورة، الاندبوينت هو showReportToSupervisors والنوع POST
      return await _apiService.post('showReportToSupervisors');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateAssignmentStatus({
    required int assignmentId,
    required String status,
    String? comment,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'status': status,
        if (comment != null) 'comment': comment,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath),
      });

      return await _apiService.post('assignments/$assignmentId/update', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  /// تأكيد إتمام البلاغ (حفظ التأكيد) باستخدام الموديل
  Future<Response> storeConfirmation(ConfirmationModel confirmation) async {
    try {
      final formData = FormData.fromMap({
        'assignment_id': confirmation.assignmentId,
        'note': confirmation.note,
        'image': await MultipartFile.fromFile(confirmation.image),
      });

      return await _apiService.post('ConfirmationStore', data: formData);
    } catch (e) {
      rethrow;
    }
  }
}