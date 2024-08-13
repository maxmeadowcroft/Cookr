import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class UserData {
  final int? id;
  final int weight;
  final int height;
  final int age;
  final String gender;
  final int activityLevel;
  final int seenRecipes;
  final int cookedRecipes;
  final int hasPremium;
  final int goals;
  final int hasSeenWelcome;

  UserData({
    this.id,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.seenRecipes,
    required this.cookedRecipes,
    required this.hasPremium,
    required this.goals,
    required this.hasSeenWelcome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'seen_recipes': seenRecipes,
      'cooked_recipes': cookedRecipes,
      'has_premium': hasPremium,
      'goals': goals,
      'has_seen_welcome': hasSeenWelcome,
    };
  }

  static UserData fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      weight: map['weight'],
      height: map['height'],
      age: map['age'],
      gender: map['gender'],
      activityLevel: map['activity_level'],
      seenRecipes: map['seen_recipes'],
      cookedRecipes: map['cooked_recipes'],
      hasPremium: map['has_premium'],
      goals: map['goals'],
      hasSeenWelcome: map['has_seen_welcome'],
    );
  }

  UserData copyWith({
    int? id,
    int? weight,
    int? height,
    int? age,
    String? gender,
    int? activityLevel,
    int? seenRecipes,
    int? cookedRecipes,
    int? hasPremium,
    int? goals,
    int? hasSeenWelcome,
  }) {
    return UserData(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      seenRecipes: seenRecipes ?? this.seenRecipes,
      cookedRecipes: cookedRecipes ?? this.cookedRecipes,
      hasPremium: hasPremium ?? this.hasPremium,
      goals: goals ?? this.goals,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
    );
  }
}

class UserDataDatabaseHelper {
  Future<int> createUserData(UserData userData) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('user_data', userData.toMap());
  }

  Future<UserData?> getUserData(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'user_data',
      columns: [
        'id',
        'weight',
        'height',
        'age',
        'gender',
        'activity_level',
        'seen_recipes',
        'cooked_recipes',
        'has_premium',
        'goals',
        'has_seen_welcome'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserData.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<UserData>> getAllUserData() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('user_data');
    return result.map((map) => UserData.fromMap(map)).toList();
  }

  Future<int> updateUserData(UserData userData) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'user_data',
      userData.toMap(),
      where: 'id = ?',
      whereArgs: [userData.id],
    );
  }

  Future<int> deleteUserData(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'user_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
