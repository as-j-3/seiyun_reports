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

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'seiyun_reports_v1.db');
    return await openDatabase(
      path,
      version:
          8, // 🚀 تم رفع النسخة إلى 8 لإضافة جدول تخزين بيانات الهوم (Home Cache)
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // إذا كان المستخدم عنده نسخة قديمة، نقوم بإنشاء جدول المهام
    if (oldVersion < 3) {
      await _createAssignmentsTable(db);
    }
    // 🆕 تحديث النسخة 4: إضافة حقول التأكيد لجدول المهام
    if (oldVersion < 4) {
      try {
        await db.execute(
          'ALTER TABLE assignments ADD COLUMN confirmation_note TEXT',
        );
        await db.execute(
          'ALTER TABLE assignments ADD COLUMN confirmation_image TEXT',
        );
      } catch (e) {
        print("Columns might already exist: $e");
      }
    }
    // 🆕 تحديث النسخة 5: إعادة إنشاء جدول بلاغات المواطنين بدون حقول الإعجاب
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
          report_image TEXT,
          imageAfterProcessing TEXT,
          created_at TEXT,
          user_name TEXT,
          user_profile TEXT
        )
      ''');
    }
    // 🆕 تحديث النسخة 6: إضافة حقول أسماء المناطق لجدول بلاغات المواطن
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE reports ADD COLUMN area_name TEXT');
        await db.execute('ALTER TABLE reports ADD COLUMN square_name TEXT');
      } catch (e) {
        print(
          "Columns area_name/square_name might already exist in reports: $e",
        );
      }
    }
    // 🆕 تحديث النسخة 7: إضافة جدول مواقيت الرفع
    if (oldVersion < 7) {
      await _createPickupSchedulesTable(db);
    }
    // 🆕 تحديث النسخة 8: إضافة جدول تخزين الهوم
    if (oldVersion < 8) {
      await _createHomeCacheTable(db);
    }
  }

  // دالة لإنشاء جدول تخزين بيانات الهوم
  Future<void> _createHomeCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS home_cache (
        id INTEGER PRIMARY KEY,
        data_json TEXT
      )
    ''');
  }

  // دالة لإنشاء جدول مواقيت الرفع
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

  // دالة مستقلة لإنشاء جدول المهام لتكرار استخدامها
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

  Future _onCreate(Database db, int version) async {
    // جدول الأخبار
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

    // جدول بلاغات المواطن (خاصتي)
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

    // جدول البلاغات المعلقة
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

    // جدول بلاغات المواطنين العامة
    await db.execute('''
      CREATE TABLE citizen_reports (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        viewsCount INTEGER,
        commentsCount INTEGER,
        report_image TEXT,
        imageAfterProcessing TEXT,
        created_at TEXT,
        user_name TEXT,
        user_profile TEXT
      )
    ''');

    // 2️⃣ إنشاء جدول المهام للمشرفين
    await _createAssignmentsTable(db);

    // 3️⃣ إنشاء جدول مواقيت الرفع
    await _createPickupSchedulesTable(db);

    // 4️⃣ إنشاء جدول تخزين الهوم
    await _createHomeCacheTable(db);
  }
}
