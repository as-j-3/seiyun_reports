import 'package:flutter/material.dart';
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

    //  مسح البيانات القديمة قبل إضافة الجديدة لضمان المزامنة الصحيحة
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
        debugPrint("خطأ في تحويل بلاغ محلي: $e");
        // نرجع كائن افتراضي في حالة وجود خطأ لتجنب توقف واجهة المستخدم
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

    // جلب الايدي للبلاغات  الي سوينا لها لايك  محلياً
    final List<Map<String, dynamic>> likedLocal = await db.query(
      'citizen_reports',
      columns: ['id'],
      where: 'isLiked = ?',
      whereArgs: [1],
    );
    Set<int> likedIds = likedLocal.map((m) => m['id'] as int).toSet();

    Batch batch = db.batch();

    // مسح البيانات القديمة )
    batch.delete('citizen_reports');

    for (var report in remoteReports) {
      // 3. إذا كان البلاغ موجوداً في قائمة الإعجابات المحلية، نقوم بتحديث حالته قبل الحفظ
      if (likedIds.contains(report.id)) {
        report.isLiked = true;
      }
      batch.insert(
        'citizen_reports',
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// تحديث حالة الإعجاب لبلاغ معين في قاعدة البيانات المحلية
  Future<void> updateCitizenReportLike(
    int reportId,
    bool isLiked,
    int newLikesCount,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'citizen_reports',
      {'isLiked': isLiked ? 1 : 0, 'likesCount': newLikesCount},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  /// زيادة عدد المشاهدات لبلاغ معين محلياً
  Future<void> incrementCitizenReportView(
    int reportId,
    int currentViews,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'citizen_reports',
      {'viewsCount': currentViews + 1},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  /// جلب بلاغات المواطنين العامة المخزنة محلياً
  Future<List<CitizenReportModel>> getLocalCitizenReports() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'citizen_reports',
      orderBy: 'created_at DESC',
    );
    if (maps.isEmpty) return [];

    return maps.map((map) {
      try {
        return CitizenReportModel.fromMap(map);
      } catch (e) {
        debugPrint("خطأ في تحويل بلاغ مواطنين محلي: $e");
        return CitizenReportModel(
          id: 0,
          title: "خطأ",
          description: "",
          status: "error",
          likesCount: 0,
          viewsCount: 0,
          commentsCount: 0,
          report_image: "",
          created_at: DateTime.now().toString(),
          user_name: "",
          user_profile: "",
        );
      }
    }).toList();
  }
}
