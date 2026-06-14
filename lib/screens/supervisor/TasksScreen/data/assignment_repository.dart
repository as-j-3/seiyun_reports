import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/models/assignment_model.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/models/confirmation_model.dart';
import 'package:seiyun_reports_app/core/database/assignment_local_service.dart';
import 'assignment_service.dart';

class AssignmentRepository {
  final AssignmentService _remoteService;
  final AssignmentsLocalService _localService;
  final NetworkInfo _networkInfo;

  AssignmentRepository({
    required AssignmentService remoteService,
    required AssignmentsLocalService localService,
    required NetworkInfo networkInfo,
  })  : _remoteService = remoteService,
        _localService = localService,
        _networkInfo = networkInfo;

  /// جلب كافة المهام (مع التعامل مع الحالات: إنترنت / بدون إنترنت)
  Future<List<AssignmentModel>> getAssignments() async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteService.getSupervisorAssignments();
        
        if (response.data['status'] == 'success') {
          final List data = response.data['data'];
          final assignments = data.map((json) => AssignmentModel.fromJson(json)).toList();
          
          await _localService.saveAssignments(assignments);
          return assignments;
        }
      } catch (e) {
      }
    }

    return await _localService.getLocalAssignments();
  }

  /// تحديث حالة المهمة
  Future<bool> updateAssignmentStatus({
    required int assignmentId,
    required String status,
    String? comment,
    String? imagePath,
  }) async {
    if (!await _networkInfo.isConnected) return false;

    try {
      final response = await _remoteService.updateAssignmentStatus(
        assignmentId: assignmentId,
        status: status,
        comment: comment,
        imagePath: imagePath,
      );

      if (response.data['status'] == 'success') {
        return true;
      }
    } catch (e) {
    }
    return false;
  }

  /// تأكيد إتمام البلاغ واسترجاع البيانات المحدثة
  Future<Map<String, dynamic>?> confirmAssignment(ConfirmationModel confirmation) async {
    if (!await _networkInfo.isConnected) return null;

    try {
      final response = await _remoteService.storeConfirmation(confirmation);

      if (response.data['status'] == 'success') {
        return response.data['data'];
      }
    } catch (e) {
    }
    return null;
  }
}