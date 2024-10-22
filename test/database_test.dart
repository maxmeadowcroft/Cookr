import 'package:cookr2/database/database_helper.dart';
import 'package:cookr2/database/recipe_database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'mock_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
    final directory = await MockPathProvider.getApplicationDocumentsDirectory();
    final path = join(directory.path, 'test_cookr2_database.db');
    await DatabaseHelper.instance.setDatabasePath(path);
  });

  tearDownAll(() async {
    final directory = await MockPathProvider.getApplicationDocumentsDirectory();
    final path = join(directory.path, 'test_cookr2_database.db');
    await databaseFactory.deleteDatabase(path);
  });

  group('Database Tests', () {
    test('Insert Recipe', () async {
      Recipe recipe = Recipe(
        name: 'Test Recipe',
        description: 'Test Description',
        protein: 20,
        calories: 200,
        fats: 10,
        carbs: 30,
        servings: 4,
        ingredients: ['ingredient1', 'ingredient2'],
        instructions: ['step1', 'step2'],
        imageUrl: 'http://example.com/image.png',
      );
      int id = await RecipeDatabaseHelper().createRecipe(recipe);
      expect(id, isNotNull);
    });

    test('Retrieve Recipe', () async {
      Recipe? recipe = await RecipeDatabaseHelper().getRecipe(1);
      expect(recipe, isNotNull);
      expect(recipe?.name, 'Test Recipe');
    });

    test('Update Recipe', () async {
      Recipe recipe = Recipe(
        id: 1,
        name: 'Updated Recipe',
        description: 'Updated Description',
        protein: 25,
        calories: 250,
        fats: 12,
        carbs: 35,
        servings: 5,
        ingredients: ['ingredient1', 'ingredient2', 'ingredient3'],
        instructions: ['step1', 'step2', 'step3'],
        imageUrl: 'http://example.com/updated_image.png',
      );
      int result = await RecipeDatabaseHelper().updateRecipe(recipe);
      expect(result, 1);
    });

    test('Delete Recipe', () async {
      int result = await RecipeDatabaseHelper().deleteRecipe(1);
      expect(result, 1);
    });
  });
}
