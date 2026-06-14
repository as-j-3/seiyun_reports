import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// تهيئة قاعدة البيانات المحلية وفتح الاتصال بها
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'seiyun_reports_v1.db');
    return await openDatabase(
      path,
      version: 11,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// معالجة ترقية قاعدة البيانات عند تحديث الإصدار
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await _createAssignmentsTable(db);
    }
    if (oldVersion < 4) {
      try {
        await db.execute(
          'ALTER TABLE assignments ADD COLUMN confirmation_note TEXT',
        );
        await db.execute(
          'ALTER TABLE assignments ADD COLUMN confirmation_image TEXT',
        );
      } catch (e) {
      }
    }
    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS citizen_reports');
      await db.execute('''
        CREATE TABLE citizen_reports (
          id INTEGER PRIMARY KEY,
          title TEXT,
          description TEXT,
          status TEXT,
          viewsCount INTEGER,
          commentsCount INTEGER,
          likesCount INTEGER,
          isLiked INTEGER,
          report_image TEXT,
          imageAfterProcessing TEXT,
          created_at TEXT,
          user_name TEXT,
          user_profile TEXT
        )
      ''');
    }
    if (oldVersion < 10) {
      try {
        await db.execute('ALTER TABLE citizen_reports ADD COLUMN likesCount INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE citizen_reports ADD COLUMN isLiked INTEGER DEFAULT 0');
      } catch (e) {
      }
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE reports ADD COLUMN area_name TEXT');
        await db.execute('ALTER TABLE reports ADD COLUMN square_name TEXT');
      } catch (e) {
      }
    }
    if (oldVersion < 7) {
      await _createPickupSchedulesTable(db);
    }
    if (oldVersion < 8) {
      await _createHomeCacheTable(db);
    }
    if (oldVersion < 9) {
      await _createNotificationsTable(db);
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE notifications ADD COLUMN user_id TEXT DEFAULT ""');
      } catch (e) {
      }
    }
  }

  /// إنشاء جدول تخزين بيانات الصفحة الرئيسية
  Future<void> _createHomeCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS home_cache (
        id INTEGER PRIMARY KEY,
        data_json TEXT
      )
    ''');
  }

  /// إنشاء جدول الإشعارات المحلية
  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        time TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        user_id TEXT DEFAULT ""
      )
    ''');
  }

  /// إنشاء جدول مواقيت رفع النفايات
  Future<void> _createPickupSchedulesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pickup_schedules (
        id INTEGER PRIMARY KEY,
        location_name TEXT,
        name_street TEXT,
        lat REAL,
        lng REAL,
        distance TEXT,
        walking_time TEXT,
        area_name TEXT,
        period TEXT,
        area_start_time TEXT,
        area_end_time TEXT,
        status TEXT,
        schedule_days TEXT
      )
    ''');
  }

  /// إنشاء جدول المهام المسندة للمشرفين
  Future<void> _createAssignmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assignments (
        id_assignments INTEGER PRIMARY KEY,
        report_id INTEGER,
        status TEXT,
        report_type TEXT,
        priority TEXT,
        title TEXT,
        description TEXT,
        report_image TEXT,
        supervisor_name TEXT,
        assigned_at TEXT,
        square TEXT,
        area TEXT,
        lat TEXT,
        lng TEXT,
        confirmation_note TEXT,
        confirmation_image TEXT
      )
    ''');
  }

  /// إنشاء جميع جداول قاعدة البيانات عند التثبيت الأول
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE news (
        id INTEGER PRIMARY KEY,
        admin_id INTEGER,
        title TEXT,
        content TEXT,
        image TEXT,
        is_active INTEGER,
        type TEXT,
        category TEXT,
        publish_date TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY,
        citizen_id INTEGER,
        title TEXT,
        area_id INTEGER,
        area_name TEXT,
        square_name TEXT,
        description TEXT,
        image TEXT,
        status TEXT,
        report_type TEXT,
        lat TEXT,
        lng TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
     CREATE TABLE pending_reports (
      local_id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      report_type TEXT,
      priority TEXT,
      lat TEXT,
      lng TEXT,
      image_path TEXT 
    )
    ''');

    await db.execute('''
      CREATE TABLE citizen_reports (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        viewsCount INTEGER,
        commentsCount INTEGER,
        likesCount INTEGER,
        isLiked INTEGER,
        report_image TEXT,
        imageAfterProcessing TEXT,
        created_at TEXT,
        user_name TEXT,
        user_profile TEXT
      )
    ''');

    await _createAssignmentsTable(db);
    await _createPickupSchedulesTable(db);
    await _createHomeCacheTable(db);
    await _createNotificationsTable(db);
  }
}
