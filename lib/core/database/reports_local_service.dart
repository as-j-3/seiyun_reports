import 'package:sqflite/sqflite.dart';
import 'package:seiyun_reports_app/screens/report/models/report_model.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/models/citizen_report_model.dart';
import 'package:seiyun_reports_app/core/database/database_helper.dart';

class ReportsLocalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// حفظ البلاغات الشخصية الخاصة بالمستخدم والقادمة من السيرفر
  Future<void> saveReports(List<ReportModel> reportsList) async {
    final db = await _dbHelper.database;
    Batch batch = db.batch();

    batch.delete('reports');

    for (var report in reportsList) {
      batch.insert(
        'reports',
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// جلب بلاغاتي المخزنة على الجهاز
  Future<List<ReportModel>> getLocalReports() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      orderBy: 'created_at DESC',
    );
    if (maps.isEmpty) return [];

    return maps.map((map) {
      try {
        return ReportModel.fromMap(map);
      } catch (e) {
        return ReportModel(
          id: 0,
          citizenId: 0,
          title: "خطأ في البيانات",
          description: "",
          image: "",
          status: "error",
          reportType: "",
          lat: "0.0",
          lng: "0.0",
          createdAt: DateTime.now().toString(),
        );
      }
    }).toList();
  }

  /// حفظ بلاغ في قائمة "الانتظار" عند عدم وجود إنترنت
  Future<void> savePendingReport(
    String title,
    String description,
    String type,
    String priority,
    String lat,
    String lng,
    String imagePath,
  ) async {
    final db = await _dbHelper.database;
    await db.insert('pending_reports', {
      'title': title,
      'description': description,
      'report_type': type,
      'priority': priority,
      'lat': lat,
      'lng': lng,
      'image_path': imagePath,
    });
  }

  /// جلب البلاغات التي لم تُرفع بعد لمزامنتها لاحقاً
  Future<List<Map<String, dynamic>>> getPendingReports() async {
    final db = await _dbHelper.database;
    return await db.query('pending_reports');
  }

  /// حذف البلاغ من قائمة الانتظار بعد نجاح عملية الرفع للسيرفر
  Future<void> deletePendingReport(int localId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'pending_reports',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  /// حفظ بلاغات المواطنين العامة
  Future<void> saveCitizenReports(
    List<CitizenReportModel> remoteReports,
  ) async {
    final db = await _dbHelper.database;

    Batch batch = db.batch();

    batch.delete('citizen_reports');

    for (var report in remoteReports) {
      batch.insert(
        'citizen_reports',
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }


  /// جلب بلاغات المواطنين العامة المخزنة محلياً
  Future<List<CitizenReportModel>> getLocalCitizenReports() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'citizen_reports',
      orderBy: 'created_at DESC',
    );
    if (maps.isEmpty) return [];

    List<CitizenReportModel> reports = [];
    for (var map in maps) {
      try {
        reports.add(CitizenReportModel.fromMap(map));
      } catch (e) {
      }
    }
    return reports;
  }
  /// زيادة عدد المشاهدات لبلاغ معين محلياً بالقيمة الجديدة مباشرة
  Future<void> incrementCitizenReportView(int reportId, int newViewsCount) async {
    final db = await _dbHelper.database;
    await db.update(
      'citizen_reports',
      {'viewsCount': newViewsCount},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  /// تحديث حالة الإعجاب والعداد الخاص به محلياً فوراً
  Future<void> updateCitizenReportLikeLocal(int reportId, bool isLiked, int likesCount) async {
    final db = await _dbHelper.database;
    await db.update(
      'citizen_reports',
      {
        'isLiked': isLiked ? 1 : 0,
        'likesCount': likesCount,
      },
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }
}
