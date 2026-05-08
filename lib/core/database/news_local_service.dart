import 'package:seiyun_reports_app/screens/news_tips/data/news_tips_model.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// كلاس مسؤول عن عمليات الحفظ والاسترجاع للأخبار والنصائح من قاعدة البيانات المحلية
class NewsLocalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// حفظ قائمة من الأخبار في قاعدة البيانات المحلية
  Future<void> saveNews(List<NewsModel> newsList) async {
    final db = await _dbHelper.database;
    // نستخدم Batch (الدفعة) لضمان سرعة إدخال كميات كبيرة من البيانات دفعة واحدة
    Batch batch = db.batch();

    for (var news in newsList) {
      batch.insert(
        'news', 
        news.toJson(), 
        // إذا كان الخبر موجوداً مسبقاً (بنفس الـ ID)، يتم استبداله بالبيانات الجديدة
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// جلب جميع الأخبار والنصائح المخزنة محلياً، مرتبة من الأحدث إلى الأقدم
  Future<List<NewsModel>> getLocalNews() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('news', orderBy: 'created_at DESC');
    
    // تحويل البيانات من Map (تنسيق قاعدة البيانات) إلى Objects (تنسيق Flutter)
    return List.generate(maps.length, (i) {
      return NewsModel.fromMap(maps[i]);
    });
  }
}