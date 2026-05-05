import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // الحصول على نسخة قاعدة البيانات، وإنشاؤها إذا لم تكن موجودة
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'seiyun_reports_v1.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS citizen_reports (
          id INTEGER PRIMARY KEY,
          title TEXT,
          description TEXT,
          status TEXT,
          likesCount INTEGER,
          viewsCount INTEGER,
          commentsCount INTEGER,
          report_image TEXT,
          imageAfterProcessing TEXT,
          created_at TEXT,
          user_name TEXT,
          user_profile TEXT,
          isLiked INTEGER
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    //  دول الأخبار والنصائح
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

    // جدول بلاغات المواطت
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY,
        citizen_id INTEGER,
        title TEXT,
        area_id INTEGER,
        description TEXT,
        image TEXT,
        status TEXT,
        report_type TEXT,
        lat TEXT,
        lng TEXT,
        created_at TEXT
      )
    ''');

    //  جدول البلاغات المعلقة هذي الي لما المواطن يرسل بلاغ بس ماعنده نت يتخزن بلاغه هنا
    await db.execute('''
     CREATE TABLE pending_reports (
      local_id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      report_type TEXT,
      priority TEXT,
      lat TEXT,
      lng TEXT,
      image_path TEXT -- سنخزن مسار الصورة في الجهاز
    )
  ''');

    //  جدول بلاغات المواطنين العامة
    await db.execute('''
      CREATE TABLE citizen_reports (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        likesCount INTEGER,
        viewsCount INTEGER,
        commentsCount INTEGER,
        report_image TEXT,
        imageAfterProcessing TEXT,
        created_at TEXT,
        user_name TEXT,
        user_profile TEXT,
        isLiked INTEGER
      )
    ''');
  }
}
