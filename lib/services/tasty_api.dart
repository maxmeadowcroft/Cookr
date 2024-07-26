import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class TastyApi {
  static const String apiKey = 'c08a75c3f5msh23bb7a7daf11bf9p1e61ddjsnf8b93a0e79b1';
  static const String apiHost = 'tasty.p.rapidapi.com';
  static const int cacheLimit = 10;

  http.Client? client;

  TastyApi() {
    _createApiCacheTable();
  }

  Future<void> _createApiCacheTable() async {
    final db = await DatabaseHelper.instance.database;
    await db.execute('''
    CREATE TABLE IF NOT EXISTS api_cache (
      endpoint TEXT PRIMARY KEY,
      response TEXT,
      timestamp INTEGER
    )
    ''');
  }

  Future<Map<String, dynamic>> fetchRecipes({int from = 0, int size = 20, String tags = ''}) async {
    final endpoint = 'recipes/list?from=$from&size=$size&tags=$tags';
    final cachedData = await _getCachedData(endpoint);
    if (cachedData != null) {
      return cachedData;
    }

    final response = await (client ?? http.Client()).get(
      Uri.parse('https://$apiHost/$endpoint'),
      headers: {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': apiHost,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await _cacheData(endpoint, data);
      return data;
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Map<String, dynamic>> fetchRandomRecipes() async {
    final random = Random();
    final int from = random.nextInt(8000);
    const int size = 10;

    return fetchRecipes(from: from, size: size);
  }

  Future<void> _cacheData(String endpoint, Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'api_cache',
      {
        'endpoint': endpoint,
        'response': jsonEncode(data),
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _cleanUpCache();
  }

  Future<void> _cleanUpCache() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM api_cache'));

    if (count != null && count > cacheLimit) {
      await db.delete('api_cache', where: 'timestamp IN (SELECT timestamp FROM api_cache ORDER BY timestamp ASC LIMIT ?)', whereArgs: [count - cacheLimit]);
    }
  }

  Future<Map<String, dynamic>?> _getCachedData(String endpoint) async {
    final db = await DatabaseHelper.instance.database;
    final cachedData = await db.query(
      'api_cache',
      where: 'endpoint = ?',
      whereArgs: [endpoint],
    );

    if (cachedData.isNotEmpty) {
      final cacheTime = cachedData.first['timestamp'] as int;
      const cacheDuration = Duration(hours: 24);

      if (DateTime.now().millisecondsSinceEpoch - cacheTime < cacheDuration.inMilliseconds) {
        return jsonDecode(cachedData.first['response'] as String);
      } else {
        await db.delete('api_cache', where: 'endpoint = ?', whereArgs: [endpoint]);
      }
    }

    return null;
  }
}
