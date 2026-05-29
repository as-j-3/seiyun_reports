import 'package:sqflite/sqflite.dart';
import 'package:seiyun_reports_app/core/database/database_helper.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/models/pickup_schedule_model.dart';

class PickupSchedulesLocalService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> saveSchedules(List<PickupScheduleModel> schedules) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // مسح البيانات القديمة أولاً
      await txn.delete('pickup_schedules');

      for (var schedule in schedules) {
        await txn.insert('pickup_schedules', {
          'id': schedule.id,
          'location_name': schedule.locationName,
          'name_street': schedule.nameStreet,
          'lat': schedule.latitude,
          'lng': schedule.longitude,
          'distance': schedule.distance,
          'walking_time': schedule.walkingTime,
          'area_name': schedule.areaName,
          'period': schedule.period,
          'area_start_time': schedule.areaStartTime,
          'area_end_time': schedule.areaEndTime,
          'status': schedule.status,
          'schedule_days': schedule.scheduleDays,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<PickupScheduleModel>> getSchedules() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pickup_schedules');

    return List.generate(maps.length, (i) {
      return PickupScheduleModel(
        id: maps[i]['id'],
        locationName: maps[i]['location_name'] ?? '',
        nameStreet: maps[i]['name_street'],
        latitude: maps[i]['lat'] ?? 0.0,
        longitude: maps[i]['lng'] ?? 0.0,
        distance: maps[i]['distance'] ?? '',
        walkingTime: maps[i]['walking_time'] ?? '',
        areaName: maps[i]['area_name'] ?? '',
        period: maps[i]['period'] ?? '',
        areaStartTime: maps[i]['area_start_time'] ?? '',
        areaEndTime: maps[i]['area_end_time'] ?? '',
        status: maps[i]['status'] ?? '',
        scheduleDays: maps[i]['schedule_days'] ?? '',
      );
    });
  }

  Future<void> clearSchedules() async {
    final db = await _dbHelper.database;
    await db.delete('pickup_schedules');
  }
}
