import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:seiyun_reports_app/core/database/database_helper.dart';
import '../models/home_data_model.dart';

class HomeLocalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// يحفظ بيانات الصفحة الرئيسية في قاعدة البيانات المحلية (الكاش).
  Future<void> saveHomeData(HomeDataModel data) async {
    final db = await _dbHelper.database;
    final String jsonString = jsonEncode(data.toJson());

    await db.insert('home_cache', {
      'id': 1, 
      'data_json': jsonString,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// يسترجع بيانات الصفحة الرئيسية المخزنة محلياً من الكاش.
  Future<HomeDataModel?> getHomeData() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'home_cache',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      final String jsonString = maps.first['data_json'];
      return HomeDataModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  /// يمسح الكاش الخاص ببيانات الصفحة الرئيسية من قاعدة البيانات.
  Future<void> clearCache() async {
    final db = await _dbHelper.database;
    await db.delete('home_cache');
  }
}
