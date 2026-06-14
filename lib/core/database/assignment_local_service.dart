import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/models/assignment_model.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class AssignmentsLocalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// حفظ المهام (Assignments) القادمة من السيرفر في الكاش المحلي
  Future<void> saveAssignments(List<AssignmentModel> assignmentsList) async {
    final db = await _dbHelper.database;
    Batch batch = db.batch();

    batch.delete('assignments');

    for (var assignment in assignmentsList) {
      batch.insert(
        'assignments',
        assignment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// جلب المهام المخزنة محلياً على جهاز المشرف
  Future<List<AssignmentModel>> getLocalAssignments() async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'assignments',
      orderBy: 'assigned_at DESC',
    );

    if (maps.isEmpty) return [];

    return maps.map((map) {
      try {
        return AssignmentModel.fromMap(map);
      } catch (e) {
        return AssignmentModel(
          idAssignments: 0,
          reportId: 0,
          status: "خطأ",
          reportType: "",
          priority: "",
          title: "خطأ في قراءة البيانات",
          description: "",
          reportImage: "",
          supervisorName: "",
          assignedAt: DateTime.now().toString(),
          square: "",
          area: "",
          lat: "0.0",
          lng: "0.0",
        );
      }
    }).toList();
  }

  /// حذف مهمة معينة محلياً (إذا لزم الأمر)
  Future<void> deleteAssignment(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'assignments',
      where: 'id_assignments = ?',
      whereArgs: [id],
    );
  }

  /// تنظيف كافة المهام (مثلاً عند تسجيل الخروج)
  Future<void> clearAllAssignments() async {
    final db = await _dbHelper.database;
    await db.delete('assignments');
  }
}