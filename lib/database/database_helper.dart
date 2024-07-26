import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  static String? _databasePath;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (_databasePath == null) {
      _databasePath = join(await getDatabasesPath(), 'cookr2_database.db');
    }

    _database = await _initDB(_databasePath!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(filePath, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE recipes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      protein INTEGER,
      calories INTEGER,
      fats INTEGER,
      carbs INTEGER,
      servings INTEGER,
      ingredients TEXT,
      instructions TEXT,
      imageUrl TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE user_data(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      activity_level INTEGER,
      seen_recipes INTEGER,
      cooked_recipes INTEGER,
      has_premium INTEGER,
      goals INTEGER,
      has_seen_welcome INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE last_10_days(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      calories INTEGER,
      protein INTEGER,
      fats INTEGER,
      carbs INTEGER,
      weight REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE meal_planning(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      breakfast INTEGER,
      lunch INTEGER,
      dinner INTEGER,
      snack INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE api_cache(
      endpoint TEXT PRIMARY KEY,
      response TEXT,
      timestamp INTEGER
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE user_data ADD COLUMN has_seen_welcome INTEGER DEFAULT 0
      ''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> setDatabasePath(String path) async {
    _databasePath = path;
    _database = await _initDB(path);
  }
}
