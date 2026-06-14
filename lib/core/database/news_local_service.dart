import 'package:seiyun_reports_app/screens/news_tips/models/news_tips_model.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// كلاس مسؤول عن عمليات الحفظ والاسترجاع للأخبار والنصائح من قاعدة البيانات المحلية
class NewsLocalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// حفظ قائمة من الأخبار في قاعدة البيانات المحلية
  Future<void> saveNews(List<NewsModel> newsList) async {
    final db = await _dbHelper.database;
    Batch batch = db.batch();

    for (var news in newsList) {
      batch.insert(
        'news', 
        news.toJson(), 
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// جلب جميع الأخبار والنصائح المخزنة محلياً، مرتبة من الأحدث إلى الأقدم
  Future<List<NewsModel>> getLocalNews() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('news', orderBy: 'created_at DESC');
    
    return List.generate(maps.length, (i) {
      return NewsModel.fromMap(maps[i]);
    });
  }
  /// مزامنة كاملة للأخبار: مسح البيانات القديمة وحفظ البيانات الجديدة القادمة من السيرفر
  Future<void> syncNewsTable(List<NewsModel> remoteNewsList) async {
    final db = await _dbHelper.database;
    Batch batch = db.batch();

    batch.delete('news');

    for (var news in remoteNewsList) {
      batch.insert(
        'news',
        news.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
}
