import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/data/assignment_repository.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/models/assignment_model.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/models/confirmation_model.dart';
import 'package:seiyun_reports_app/core/database/assignment_local_service.dart';

class SupervisorTasksViewModel extends ChangeNotifier {
  final AssignmentRepository _repository;
  Timer? _autoRefreshTimer;

  SupervisorTasksViewModel(this._repository) {
    fetchAssignments();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchAssignments(showLoading: false);
    });
  }

  List<AssignmentModel> _assignments = [];
  List<AssignmentModel> get assignments => _assignments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAssignments({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _assignments = await _repository.getAssignments();
    } catch (e) {
      debugPrint("Error fetching assignments: $e");
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> updateAssignmentStatus({
    required int assignmentId,
    required String status,
    String? comment,
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.updateAssignmentStatus(
        assignmentId: assignmentId,
        status: status,
        comment: comment,
        imagePath: imagePath,
      );
      if (success) {
        await fetchAssignments(); // Refresh list on success
      }
      return success;
    } catch (e) {
      debugPrint("Error updating status: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تأكيد إتمام البلاغ من قبل المشرف
  Future<bool> confirmTask({
    required int assignmentId,
    required String note,
    required String imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final confirmation = ConfirmationModel(
        assignmentId: assignmentId,
        note: note,
        image: imagePath,
      );

      final confirmationData = await _repository.confirmAssignment(confirmation);
      
      if (confirmationData != null) {
        // تحديث المهمة في القائمة المحلية فوراً لضمان ظهور البيانات في التفاصيل
        final index = _assignments.indexWhere((a) => a.idAssignments == assignmentId);
        if (index != -1) {
          _assignments[index] = _assignments[index].copyWith(
            status: 'completed', // أو 'solved' حسب المعتمد في السيرفر
            confirmationNote: confirmationData['note'],
            confirmationImage: confirmationData['image'],
          );
          
          // حفظ التحديث في قاعدة البيانات المحلية أيضاً لضمان الاستمرارية
          final localService = AssignmentsLocalService(); // أو جلبها من الـ Repository إذا كانت عامة
          await localService.saveAssignments(_assignments);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error confirming task: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AssignmentModel> get pendingTasks => 
      _assignments.where((t) => 
        t.status == 'قيد الانتظار' || 
        t.status == 'pending' || 
        t.status == 'قيد المعالجة' || 
        t.status == 'processing'
      ).toList();

  List<AssignmentModel> get completedTasks => 
      _assignments.where((t) => 
        t.status == 'تم الحل' || 
        t.status == 'solved' || 
        t.status == 'مكتملة' ||
        t.status == 'completed'
      ).toList();
  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
