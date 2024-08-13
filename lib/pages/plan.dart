import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'swipe.dart';
import '../util/colors.dart';
import '../components/primary_button.dart';
import '../components/primary_progress_bar.dart';
import '../components/secondary_progress_bar.dart';
import '../components/calendar_week.dart';
import '../components/custom_card.dart';
import '../components/to_do_item.dart';
import '../database/recipe_database_helper.dart';
import '../database/user_data_database_helper.dart';
import '../database/database_helper.dart';
import '../services/macro_calculator_service.dart';
import '../components/expanded_card.dart';
import '../components/secondary_button.dart';
import '../components/third_button.dart';
import '../util/string_extensions.dart';
import '../components/full_calendar.dart';
import '../services/subscriptions.dart';

class PlanPage extends StatefulWidget {
  final SubscriptionService subscriptionService;

  PlanPage({required this.subscriptionService});

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _mealPlans = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snack': [],
  };
  Map<String, int> _totalMacros = {
    'calories': 0,
    'protein': 0,
    'fats': 0,
    'carbs': 0,
  };
  Map<String, int> _dailyGoals = {
    'calories': 0,
    'protein': 0,
    'fats': 0,
    'carbs': 0,
  };
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _loadDailyGoals();
    _loadMealPlans();
  }

  Future<void> _checkPremiumStatus() async {
    final userDataDatabaseHelper = UserDataDatabaseHelper();
    final userData = await userDataDatabaseHelper.getUserData(1); // Assuming user ID 1 for this example
    if (userData != null) {
      setState(() {
        _isPremium = userData.hasPremium == 1;
      });
    }
  }

  Future<void> _loadDailyGoals() async {
    final userDataDatabaseHelper = UserDataDatabaseHelper();
    final userData = await userDataDatabaseHelper.getUserData(1); // Assuming user ID 1 for this example
    if (userData != null) {
      final macroCalculator = MacroCalculatorService();
      final activityLevelIndex = userData.activityLevel.clamp(0, ActivityLevel.values.length - 1);
      final goalIndex = userData.goals.clamp(0, Goal.values.length - 1);
      final activityLevel = ActivityLevel.values[activityLevelIndex];
      final goal = Goal.values[goalIndex];

      final goals = macroCalculator.calculateMacros(
          userData.weight, userData.height, userData.age, userData.gender, activityLevel, goal);

      setState(() {
        _dailyGoals = goals;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _loadMealPlans();
    });
  }

  Future<void> _loadMealPlans() async {
    final mealPlanIds = await DatabaseHelper.instance.getMealPlan(_selectedDate);
    print("Loaded Meal Plans for $_selectedDate: $mealPlanIds"); // Debug statement

    setState(() {
      _mealPlans = mealPlanIds;
      _calculateTotalMacros();
    });
  }

  void _showExpandedCard(BuildContext context, Recipe recipe, String mealType, {bool isSaved = false}) {
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
              if (isSaved)
                ...[
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
                      setState(() {
                        _mealPlans[mealType]?.removeWhere((meal) => meal['recipe'].id == recipe.id);
                      });
                      _saveMealPlans();
                    },
                  ),
                ]
              else
                SecondaryButton(
                  text: 'Add to Day',
                  onPressed: () {
                    Navigator.pop(context);
                    _promptForServings(mealType, recipe);
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
                  'fats': (currentEntry['fat'] ?? 0) + (macros['fat']! * servings),
                  'carbs': (currentEntry['carbohydrates'] ?? 0) + (macros['carbohydrates']! * servings),
                };

                await dbHelper.logMacros(
                  selectedDate,
                  updatedMacros['calories']!,
                  updatedMacros['protein']!,
                  updatedMacros['fats']!,
                  updatedMacros['carbohydrates']!,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: AppColors.backgroundColor,
        );
      },
    );
  }

  Future<void> _showSavedRecipesDialog(String mealType) async {
    final savedRecipes = await RecipeDatabaseHelper().getAllRecipes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: AppColors.backgroundColor,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 70, left: 16), // Adjust padding to position the button
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, size: 32), // Increase the size of the icon
                    color: AppColors.textColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cards per row
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 200 / 300,
                  ),
                  padding: EdgeInsets.all(10),
                  itemCount: savedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = savedRecipes[index];
                    final truncatedTitle = recipe.name.truncateWithEllipsis(16);
                    final macros = {
                      'Calories': recipe.calories,
                      'Protein': recipe.protein,
                      'Fats': recipe.fats,
                      'Carbs': recipe.carbs,
                    };

                    return GestureDetector(
                      onTap: () => _showExpandedCard(context, recipe, mealType),
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
                              height: 15, // Slightly increased height of the progress bar
                              width: 150,
                            )
                                : SecondaryProgressBar(
                              progress: progress.clamp(0.0, 1.0),
                              height: 15, // Slightly increased height of the secondary progress bar
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
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _promptForServings(String mealType, Recipe recipe) async {
    Navigator.of(context).pop(); // Pop the context before showing the dialog
    await Future.delayed(Duration(milliseconds: 200)); // Short delay to ensure the modal is closed

    final TextEditingController servingsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "How many servings?",
            style: TextStyle(color: AppColors.textColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: servingsController,
                  decoration: InputDecoration(labelText: "Servings", labelStyle: TextStyle(color: AppColors.textColor)),
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
              child: Text("Add", style: TextStyle(color: AppColors.buttonColor)),
              onPressed: () {
                final int servings = int.tryParse(servingsController.text) ?? 1;
                Navigator.of(context).pop();
                setState(() {
                  _mealPlans[mealType]?.add({'recipe': recipe, 'servings': servings});
                });
                _saveMealPlans();
                _calculateTotalMacros();
              },
            ),
          ],
          backgroundColor: AppColors.backgroundColor,
        );
      },
    );
  }

  Future<void> _saveMealPlans() async {
    print("Saving Meal Plans for $_selectedDate: $_mealPlans"); // Debug statement
    await DatabaseHelper.instance.saveMealPlan(_selectedDate, _mealPlans);
    print("Meal Plans saved successfully"); // Debug statement
  }

  void _calculateTotalMacros() {
    Map<String, int> totalMacros = {
      'calories': 0,
      'protein': 0,
      'fats': 0,
      'carbs': 0,
    };

    _mealPlans.forEach((mealType, meals) {
      for (var meal in meals) {
        Recipe recipe = meal['recipe'];
        int servings = meal['servings'];
        totalMacros['calories'] = totalMacros['calories']! + (recipe.calories * servings);
        totalMacros['protein'] = totalMacros['protein']! + (recipe.protein * servings);
        totalMacros['fats'] = totalMacros['fats']! + (recipe.fats * servings);
        totalMacros['carbs'] = totalMacros['carbs']! + (recipe.carbs * servings);
      }
    });

    setState(() {
      _totalMacros = totalMacros;
    });
  }

  void _showFullPageCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          color: AppColors.backgroundColor,
          child: CustomFullPageCalendar(
            onSelectedDates: (List<DateTime> selectedDates) {
              // Get ingredients from the selected dates
              _getIngredientsForSelectedDates(selectedDates);
            },
          ),
        );
      },
    );
  }

  Future<void> _getIngredientsForSelectedDates(List<DateTime> selectedDates) async {
    List<String> ingredients = [];
    for (DateTime date in selectedDates) {
      final mealPlans = await DatabaseHelper.instance.getMealPlan(date);
      mealPlans.forEach((mealType, meals) {
        for (var meal in meals) {
          Recipe recipe = meal['recipe'];
          ingredients.addAll(recipe.ingredients);
        }
      });
    }
    Navigator.pop(context);
    _showIngredientsPage(ingredients);
  }

  void _showIngredientsPage(List<String> ingredients) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientsPage(ingredients: ingredients),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.encodeSans(
            textStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._mealPlans[title]!.map((mealPlan) {
                final recipe = mealPlan['recipe'] as Recipe;
                final servings = mealPlan['servings'] as int;
                final truncatedTitle = '${servings} servings - ${recipe.name.truncateWithEllipsis(16)}';
                return GestureDetector(
                  onTap: () => _showExpandedCard(context, recipe, title, isSaved: true),
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        CustomCard(
                          width: 150,
                          height: 200,
                          imageUrl: recipe.imageUrl,
                          title: truncatedTitle,
                          titleSize: 16,
                          children: [],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              GestureDetector(
                onTap: () => _showSavedRecipesDialog(title),
                child: CustomCard(
                  width: 150,
                  height: 200,
                  imageUrl: '', // No image for the add button
                  title: "+",
                  titleSize: 64,
                  children: [],
                  isAddButton: true, // Indicate this is the add button
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroProgress(String name, String key, int goal, int consumed, bool usePrimary, [bool showUnit = false]) {
    final remaining = goal - consumed;
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final unit = showUnit ? 'g' : ''; // Unit to show if necessary

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$name: $consumed$unit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'Remaining: $remaining$unit',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth; // Use 100% of the available width
            return usePrimary
                ? ProgressBar(
              progress: progress,
              height: 15,
              width: width,
            )
                : SecondaryProgressBar(
              progress: progress,
              height: 15,
              width: width,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isPremium
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan',
                  style: GoogleFonts.encodeSans(
                    textStyle: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                PrimaryButton(
                  text: 'List',
                  onPressed: _showFullPageCalendar,
                ),
              ],
            ),
            SizedBox(height: 20),
            CustomCalendarWeek(
              initialDate: _selectedDate,
              onDateSelected: _onDateSelected,
              startDate: DateTime.now().subtract(Duration(days: 10)),
              endDate: DateTime.now().add(Duration(days: 30)),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildMacroProgress('Calories', 'calories', _dailyGoals['calories']!, _totalMacros['calories']!, true)),
                SizedBox(width: 16),
                Expanded(child: _buildMacroProgress('Protein', 'protein', _dailyGoals['protein']!, _totalMacros['protein']!, false, true)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildMacroProgress('Fats', 'fats', _dailyGoals['fats']!, _totalMacros['fats']!, true, true)),
                SizedBox(width: 16),
                Expanded(child: _buildMacroProgress('Carbs', 'carbs', _dailyGoals['carbs']!, _totalMacros['carbs']!, false, true)),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  _buildSection('Breakfast'),
                  _buildSection('Lunch'),
                  _buildSection('Dinner'),
                  _buildSection('Snack'),
                ],
              ),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100,),
              Text(
                'Plan',
                style: GoogleFonts.encodeSans(
                  textStyle: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'This section is only available to premium users. With it, you can plan out your meals and get grocery lists.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Subscribe to premium for just \$4.99/month to access all features.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
              PrimaryButton(
                text: 'Subscribe',
                onPressed: () {
                  widget.subscriptionService.buyPremiumSubscription();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IngredientsPage extends StatelessWidget {
  final List<String> ingredients;

  IngredientsPage({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Ingredients',
          style: GoogleFonts.encodeSans(
            textStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(0), // Remove default padding
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return TodoItem(
                    title: ingredients[index],
                    isCompleted: false,
                    onToggle: () {
                      // Implement toggle functionality if needed
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            PrimaryButton(
              text: 'Copy List',
              onPressed: () {
                String todoListText = ingredients.join(', ');
                _copyToClipboard(context, todoListText);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    final data = ClipboardData(text: text);
    Clipboard.setData(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ingredients copied to clipboard!')),
    );
  }
}
