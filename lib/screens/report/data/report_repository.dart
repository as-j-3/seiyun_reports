import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/database/reports_local_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import 'package:seiyun_reports_app/core/utils/update_helper.dart';
import 'package:seiyun_reports_app/screens/report/models/report_model.dart';
import 'package:seiyun_reports_app/screens/report/data/report_service.dart';

class ReportRepository {
  final ReportService _reportService;
  final ReportsLocalService _localService;
  final NetworkInfo _networkInfo;

  ReportRepository(this._reportService, this._localService, this._networkInfo);

  // 1. دالة إرسال بلاغ للسيرفر أو حفظه محلياً
  Future<bool> sendNewReport({
    required String description,
    required String title,
    required String type,
    required String priority,
    required String lat,
    required String lng,
    File? imageFile,
  }) async {
    bool isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        int? userId = await PrefHelper.getUserId();

        Map<String, dynamic> formDataMap = {
          "citizen_id": userId,
          "title": title,
          "description": description,
          "report_type": type,
          "priority": priority,
          "lat": lat,
          "lng": lng,
        };

        if (imageFile != null) {
          // جلب اسم الملف بشكل آمن يدعم جميع الأنظمة
          String fileName = imageFile.path.split(RegExp(r'[/\\]')).last;

          // التأكد من وجود امتداد للملف، إذا لم يوجد نفترض أنه jpeg
          if (!fileName.contains('.')) {
            fileName += '.jpg';
          }

          // تحديد نوع المحتوى بناءً على الامتداد
          String extension = fileName.split('.').last.toLowerCase();
          String mimeType = (extension == 'png') ? 'png' : 'jpeg';

          formDataMap["image"] = await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: DioMediaType("image", mimeType),
          );
        }

        FormData formData = FormData.fromMap(formDataMap);

        final response = await _reportService.createReport(formData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        }
      } catch (e) {
        debugPrint("--- SERVER ERROR DETAILS ---");
      }
    }
    await _saveLocally(
      title,
      description,
      type,
      priority,
      lat,
      lng,
      imageFile?.path ?? '',
    );
    return isConnected ? false : true;
  }

  // 2. دالة جلب قائمة بلاغاتي (أونلاين + أوفلاين)
  Future<List<ReportModel>> fetchMyReports({bool isRefresh = false}) async {
    try {
      // جلب الكاش أولاً
      List<ReportModel> cachedReports = await _localService.getLocalReports();

      // جلب البلاغات المعلقة
      List<Map<String, dynamic>> pendingMaps =
          await _localService.getPendingReports();
      List<ReportModel> pendingReports =
          pendingMaps
              .map(
                (map) => ReportModel(
                  id: map['local_id'] ?? 0,
                  citizenId: 0,
                  title: map['title'] ?? '',
                  description: map['description'] ?? '',
                  image: map['image_path'] ?? '',
                  status: 'قيد الإنتظار',
                  reportType: map['report_type'] ?? '',
                  lat: map['lat'] ?? '0.0',
                  lng: map['lng'] ?? '0.0',
                  createdAt: DateTime.now().toString(),
                ),
              )
              .toList();

      // فحص: هل نحتاج تحديث من السيرفر؟ وهل فيه نت؟
      bool shouldSync = await UpdateHelper.canSync(
        lastUpdateKey: 'my_reports_sync',
        daysInterval: 1,
        forceUpdate: isRefresh,
      );
      bool hasInternet = await _networkInfo.isConnected;

      if (shouldSync && hasInternet) {
        if (cachedReports.isEmpty || isRefresh) {
          await _syncReportsWithServer(); // الانتظار في حالة أول تشغيل أو التحديث اليدوي
          cachedReports =
              await _localService.getLocalReports(); // إعادة الجلب بعد المزامنة
        } else {
          _syncReportsWithServer(); // مزامنة في الخلفية
        }
      }

      // دمج القائمتين
      List<ReportModel> allReports = [...pendingReports, ...cachedReports];

      return allReports;
    } catch (e) {
      debugPrint("خطأ أثناء جلب البلاغات: $e");
      return []; // نرجع قائمة فارغة لضمان عدم حدوث خطأ Null في الـ UI
    }
  }

  // دالة خاصة بالمزامنة مع السيرفر وتحديث الكاش
  Future<void> _syncReportsWithServer() async {
    try {
      final response = await _reportService.getMyReports();
      if (response.statusCode == 200) {
        List data = response.data['data'] ?? [];
        debugPrint("Fetched ${data.length} reports from server.");

        List<ReportModel> remoteReports =
            data.map((json) {
              final model = ReportModel.fromJson(json);
              if (model.id == 0) {
                debugPrint("Warning: Parsed report with ID 0. JSON: $json");
              }
              return model;
            }).toList();

        await _localService.saveReports(remoteReports);
        await UpdateHelper.saveLastUpdate('my_reports_sync'); // ختم الوقت
        debugPrint(
          "Successfully saved ${remoteReports.length} reports to local cache.",
        );
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  // مزامنة البلاغات المعلقة
  Future<void> syncPendingReports() async {
    if (!await _networkInfo.isConnected) return;
    List<Map<String, dynamic>> pending =
        await _localService.getPendingReports();
    if (pending.isEmpty) return;

    debugPrint("جاري مزامنة ${pending.length} بلاغات...");

    for (var data in pending) {
      bool success = await sendNewReport(
        title: data['title'],
        description: data['description'],
        type: data['report_type'],
        priority: data['priority'] ?? 'متوسطة',
        lat: data['lat'],
        lng: data['lng'],
        imageFile:
            (data['image_path'] != null &&
                    data['image_path'].toString().isNotEmpty)
                ? File(data['image_path'])
                : null,
      );

      if (success) {
        await _localService.deletePendingReport(data['local_id']);
      }
    }
  }

  // دالة مساعدة للحفظ المحلي
  Future<void> _saveLocally(
    String t,
    String d,
    String ty,
    String p,
    String la,
    String ln,
    String path,
  ) async {
    await _localService.savePendingReport(t, d, ty, p, la, ln, path);
    debugPrint("✅ تم حفظ البلاغ محلياً.");
  }
}
