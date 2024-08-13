import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/recipe_database_helper.dart';
import '../database/database_helper.dart';
import '../database/user_data_database_helper.dart';
import '../components/expanded_card.dart';
import '../components/primary_button.dart';
import '../components/secondary_button.dart';
import '../components/third_button.dart';
import '../components/custom_card.dart';
import '../components/primary_progress_bar.dart';
import '../components/secondary_progress_bar.dart';
import '../util/colors.dart';
import '../util/string_extensions.dart';

class SavedPage extends StatefulWidget {
  final Function refreshCallback;

  SavedPage({required this.refreshCallback, Key? key}) : super(key: key);

  @override
  SavedPageState createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  late Future<List<Recipe>> _savedRecipes;
  late Future<UserData?> _userDataFuture;
  late UserData? _userData;

  @override
  void initState() {
    super.initState();
    refreshSavedRecipes();
    _userDataFuture = UserDataDatabaseHelper().getUserData(1); // Replace with actual user ID
  }

  void refreshSavedRecipes() {
    setState(() {
      _savedRecipes = RecipeDatabaseHelper().getAllRecipes();
    });
  }

  void _showExpandedCard(BuildContext context, Recipe recipe) {
    final macros = {
      'calories': recipe.calories,
      'protein': recipe.protein,
      'fat': recipe.fats,
      'carbohydrates': recipe.carbs,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SlidingPanel(
          imageUrl: recipe.imageUrl,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '${recipe.servings} servings',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  macros.entries.map((e) => '${e.key.capitalize()}: ${e.value}g').join(' | '),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  recipe.description,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 10),
                Text(
                  'Ingredients:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.ingredients.map((ingredient) {
                    final parts = ingredient.split(': ');
                    final ingredientName = parts[0];
                    final quantityAndUnit = parts.length > 1 ? parts[1] : '';

                    return Text(
                      quantityAndUnit == '0' || quantityAndUnit.isEmpty
                          ? '- $ingredientName'
                          : '- $ingredientName: $quantityAndUnit',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.instructions.map((instruction) {
                    return Text(
                      '- $instruction',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
          bottomComponent: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SecondaryButton(
                text: 'Log',
                onPressed: () {
                  _logMeal(context, recipe, macros);
                },
              ),
              ThirdButton(
                text: 'Delete',
                onPressed: () async {
                  await RecipeDatabaseHelper().deleteRecipe(recipe.id!);
                  Navigator.pop(context);
                  refreshSavedRecipes();
                },
              ),
              PrimaryButton(
                text: 'Close',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logMeal(BuildContext context, Recipe recipe, Map<String, int> macros) {
    final TextEditingController servingsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Log Meal",
            style: TextStyle(color: AppColors.textColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: servingsController,
                  decoration: InputDecoration(labelText: "How many servings did you eat?", labelStyle: TextStyle(color: AppColors.textColor)),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: AppColors.buttonColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Log", style: TextStyle(color: AppColors.buttonColor)),
              onPressed: () async {
                final int servings = int.tryParse(servingsController.text) ?? 1;
                final dbHelper = DatabaseHelper.instance;
                final currentMacros = await dbHelper.getLast10DaysData();
                final selectedDate = DateTime.now();
                final currentEntry = currentMacros.firstWhere(
                      (entry) => entry['date'] == DateFormat('yyyy-MM-dd').format(selectedDate),
                  orElse: () => {},
                );
                final updatedMacros = {
                  'calories': (currentEntry['calories'] ?? 0) + (macros['calories']! * servings),
                  'protein': (currentEntry['protein'] ?? 0) + (macros['protein']! * servings),
                  'fats': (currentEntry['fats'] ?? 0) + (macros['fat']! * servings),
                  'carbohydrates': (currentEntry['carbohydrates'] ?? 0) + (macros['carbohydrates']! * servings),
                };

                await dbHelper.logMacros(
                  selectedDate,
                  updatedMacros['calories']!,
                  updatedMacros['protein']!,
                  updatedMacros['fats']!,
                  updatedMacros['carbohydrates']!,
                );
                Navigator.of(context).pop();
                widget.refreshCallback();
              },
            ),
          ],
          backgroundColor: AppColors.backgroundColor,
        );
      },
    );
  }

  void _handleUpgrade() {
    // Implement your upgrade logic here
    print("Upgrade button pressed");
  }

  void _replaceRecipe(int replaceId, Recipe newRecipe) async {
    await RecipeDatabaseHelper().deleteRecipe(replaceId);
    await RecipeDatabaseHelper().createRecipe(newRecipe);
    refreshSavedRecipes();
  }

  void _promptForReplacement(Recipe newRecipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Recipe>>(
          future: _savedRecipes,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              final recipes = snapshot.data!;
              return AlertDialog(
                title: Text(
                  "Replace Recipe",
                  style: TextStyle(color: AppColors.textColor),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: recipes.map((recipe) {
                      return ListTile(
                        title: Text(recipe.name),
                        onTap: () {
                          Navigator.of(context).pop();
                          _replaceRecipe(recipe.id!, newRecipe);
                        },
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text("Cancel", style: TextStyle(color: AppColors.buttonColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                backgroundColor: AppColors.backgroundColor,
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<UserData?>(
        future: _userDataFuture,
        builder: (context, userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (userDataSnapshot.hasError) {
            return Center(child: Text('Error: ${userDataSnapshot.error}'));
          } else {
            _userData = userDataSnapshot.data;
            return FutureBuilder<List<Recipe>>(
              future: _savedRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No saved recipes.'));
                } else {
                  final sortedRecipes = snapshot.data!.reversed.toList(); // Sort recipes by most recent
                  final hasPremium = _userData?.hasPremium == 1;
                  final savedCount = sortedRecipes.length;

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          'Saved',
                          style: GoogleFonts.encodeSans(
                            textStyle: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (!hasPremium)
                        Column(
                          children: [
                            Text(
                              'Saved slots used: $savedCount/10',
                              style: TextStyle(fontSize: 16, color: AppColors.textColor),
                            ),
                            SizedBox(height: 10),
                            PrimaryButton(
                              text: 'Upgrade',
                              onPressed: _handleUpgrade,
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 200 / 300,
                        ),
                        padding: EdgeInsets.all(10),
                        itemCount: sortedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = sortedRecipes[index];
                          final truncatedTitle = recipe.name.truncateWithEllipsis(16);
                          final macros = {
                            'Calories': recipe.calories,
                            'Protein': recipe.protein,
                            'Fats': recipe.fats,
                            'Carbs': recipe.carbs,
                          };

                          return GestureDetector(
                            onTap: () => _showExpandedCard(context, recipe),
                            child: CustomCard(
                              width: 200,
                              height: 300,
                              title: truncatedTitle,
                              titleSize: 14,
                              imageUrl: recipe.imageUrl,
                              imageHeight: 80,
                              children: macros.values.any((value) => value != 0)
                                  ? macros.entries.map((entry) {
                                int index = macros.keys.toList().indexOf(entry.key);
                                double maxValue;
                                switch (entry.key) {
                                  case 'Calories':
                                    maxValue = 3168;
                                    break;
                                  case 'Protein':
                                    maxValue = 176;
                                    break;
                                  case 'Fats':
                                    maxValue = 88;
                                    break;
                                  case 'Carbs':
                                    maxValue = 436;
                                    break;
                                  default:
                                    maxValue = 100;
                                    break;
                                }
                                double progress = entry.value / maxValue; // Adjust progress calculation
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0.0), // Reduced vertical padding
                                  child: index % 2 == 0
                                      ? ProgressBar(
                                    progress: progress.clamp(0.0, 1.0),
                                    height: 15,
                                    width: 150,
                                  )
                                      : SecondaryProgressBar(
                                    progress: progress.clamp(0.0, 1.0),
                                    height: 15,
                                    width: 150,
                                  ),
                                );
                              }).toList()
                                  : [
                                Text(
                                  'Macros are not available for this recipe.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
