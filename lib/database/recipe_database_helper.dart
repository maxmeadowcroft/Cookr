import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class Recipe {
  final int? id;
  final String name;
  final String description;
  final int protein;
  final int calories;
  final int fats;
  final int carbs;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final String imageUrl;

  Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.protein,
    required this.calories,
    required this.fats,
    required this.carbs,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'protein': protein,
      'calories': calories,
      'fats': fats,
      'carbs': carbs,
      'servings': servings,
      'ingredients': ingredients.join(','),
      'instructions': instructions.join(','),
      'imageUrl': imageUrl,
    };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      protein: map['protein'],
      calories: map['calories'],
      fats: map['fats'],
      carbs: map['carbs'],
      servings: map['servings'],
      ingredients: map['ingredients'].split(','),
      instructions: map['instructions'].split(','),
      imageUrl: map['imageUrl'],
    );
  }
}

class RecipeDatabaseHelper {
  Future<int> createRecipe(Recipe recipe) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<Recipe?> getRecipe(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'recipes',
      columns: [
        'id',
        'name',
        'description',
        'protein',
        'calories',
        'fats',
        'carbs',
        'servings',
        'ingredients',
        'instructions',
        'imageUrl'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Recipe.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('recipes');
    return result.map((map) => Recipe.fromMap(map)).toList();
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
