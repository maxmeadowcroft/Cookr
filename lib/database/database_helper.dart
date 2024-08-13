import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'recipe_database_helper.dart'; // Import the RecipeDatabaseHelper

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
    return await openDatabase(filePath, version: 6, onCreate: _createDB, onUpgrade: _upgradeDB);
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
      weight INTEGER,
      height INTEGER,
      age INTEGER,
      gender TEXT,
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
      date TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE meal_plan_recipes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      meal_plan_id INTEGER,
      meal_type TEXT,
      recipe_id INTEGER,
      servings INTEGER,
      FOREIGN KEY(meal_plan_id) REFERENCES meal_planning(id)
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
    if (oldVersion < 6) {
      await _createMealPlanRecipesTableIfNotExists(db);
    }
  }

  Future<void> _createMealPlanRecipesTableIfNotExists(Database db) async {
    final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table" AND name="meal_plan_recipes"');
    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE meal_plan_recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_plan_id INTEGER,
        meal_type TEXT,
        recipe_id INTEGER,
        servings INTEGER,
        FOREIGN KEY(meal_plan_id) REFERENCES meal_planning(id)
      )
      ''');
    }
  }

  Future<void> logMacros(DateTime date, int calories, int protein, int fats, int carbs) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().split('T')[0];
    final result = await db.query('last_10_days', where: 'date = ?', whereArgs: [dateString]);

    if (result.isEmpty) {
      await db.insert('last_10_days', {
        'date': dateString,
        'calories': calories,
        'protein': protein,
        'fats': fats,
        'carbs': carbs,
        'weight': 0, // Default weight value, update if needed
      });
    } else {
      await db.update('last_10_days', {
        'calories': calories,
        'protein': protein,
        'fats': fats,
        'carbs': carbs,
      }, where: 'date = ?', whereArgs: [dateString]);
    }
  }

  Future<void> logWeight(DateTime date, double weight) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().split('T')[0];
    final result = await db.query('last_10_days', where: 'date = ?', whereArgs: [dateString]);

    if (result.isEmpty) {
      await db.insert('last_10_days', {
        'date': dateString,
        'calories': 0,
        'protein': 0,
        'fats': 0,
        'carbs': 0,
        'weight': weight,
      });
    } else {
      await db.update('last_10_days', {
        'weight': weight,
      }, where: 'date = ?', whereArgs: [dateString]);
    }
  }

  Future<List<Map<String, dynamic>>> getLast10DaysData() async {
    final db = await instance.database;
    final result = await db.query('last_10_days', orderBy: 'date DESC', limit: 10);
    return result;
  }

  Future<void> resetOldestEntry() async {
    final db = await instance.database;
    final oldestEntry = await db.query('last_10_days', orderBy: 'date ASC', limit: 1);

    if (oldestEntry.isNotEmpty) {
      final oldestDate = DateTime.parse(oldestEntry.first['date'] as String);
      final today = DateTime.now();
      if (today.difference(oldestDate).inDays >= 10) {
        await db.update('last_10_days', {
          'calories': 0,
          'protein': 0,
          'fats': 0,
          'carbs': 0,
          'weight': 0,
        }, where: 'date = ?', whereArgs: [oldestDate.toIso8601String().split('T')[0]]);
      }
    }
  }

  Future<void> saveMealPlan(DateTime date, Map<String, List<Map<String, dynamic>>> mealPlans) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().split('T')[0];

    final mealPlanResult = await db.query('meal_planning', where: 'date = ?', whereArgs: [dateString]);

    int mealPlanId;
    if (mealPlanResult.isEmpty) {
      mealPlanId = await db.insert('meal_planning', {
        'date': dateString,
      });
    } else {
      mealPlanId = mealPlanResult.first['id'] as int;
    }

    // Delete existing meal plan recipes for the date
    await db.delete('meal_plan_recipes', where: 'meal_plan_id = ?', whereArgs: [mealPlanId]);

    // Insert new meal plan recipes
    mealPlans.forEach((mealType, meals) async {
      for (var meal in meals) {
        await db.insert('meal_plan_recipes', {
          'meal_plan_id': mealPlanId,
          'meal_type': mealType,
          'recipe_id': meal['recipe'].id,
          'servings': meal['servings'],
        });
      }
    });

    // Log the saved data
    final savedMealPlan = await getMealPlan(date);
    print("Meal Plan saved for $dateString: $savedMealPlan"); // Debug statement
  }

  Future<Map<String, List<Map<String, dynamic>>>> getMealPlan(DateTime date) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().split('T')[0];
    final mealPlanResult = await db.query('meal_planning', where: 'date = ?', whereArgs: [dateString]);

    if (mealPlanResult.isNotEmpty) {
      final mealPlanId = mealPlanResult.first['id'] as int;
      final mealPlanRecipesResult = await db.query('meal_plan_recipes', where: 'meal_plan_id = ?', whereArgs: [mealPlanId]);

      Map<String, List<Map<String, dynamic>>> mealPlans = {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
        'Snack': [],
      };

      for (var row in mealPlanRecipesResult) {
        String mealType = row['meal_type'] as String;
        int recipeId = row['recipe_id'] as int;
        int servings = row['servings'] as int;

        Recipe? recipe = await RecipeDatabaseHelper().getRecipe(recipeId);
        if (recipe != null) {
          mealPlans[mealType]?.add({'recipe': recipe, 'servings': servings});
        }
      }

      print("Meal Plan loaded for $dateString: $mealPlans"); // Debug statement
      return mealPlans;
    } else {
      print("No Meal Plan found for $dateString"); // Debug statement
      return {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
        'Snack': [],
      };
    }
  }

  Future<void> deleteRecipeFromPlans(int recipeId) async {
    final db = await instance.database;
    await db.delete('meal_plan_recipes', where: 'recipe_id = ?', whereArgs: [recipeId]);
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
