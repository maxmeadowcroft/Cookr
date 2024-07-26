import 'database_helper.dart';

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
