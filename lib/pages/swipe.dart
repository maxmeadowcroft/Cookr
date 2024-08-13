import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:intl/intl.dart';
import '../components/bottom_nav_bar.dart';
import '../components/custom_card.dart';
import '../components/primary_progress_bar.dart';
import '../components/secondary_progress_bar.dart';
import '../util/colors.dart';
import 'saved.dart';
import 'account.dart';
import 'macros.dart';
import 'plan.dart';
import '../services/tasty_api.dart';
import '../components/expanded_card.dart';
import '../components/primary_button.dart';
import '../components/secondary_button.dart';
import '../components/third_button.dart';
import '../components/popup.dart';
import '../database/database_helper.dart';
import '../database/recipe_database_helper.dart';
import '../database/user_data_database_helper.dart';
import '../services/macro_calculator_service.dart';
import '../util/string_extensions.dart';
import '../services/subscriptions.dart';

class SwipePage extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const SwipePage({required this.subscriptionService, super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  final List<Widget> _pages = [];
  final GlobalKey<SavedPageState> _savedPageKey = GlobalKey<SavedPageState>();
  final GlobalKey<MacrosPageState> _macrosPageKey = GlobalKey<MacrosPageState>();
  Map<String, int> _goals = {};

  @override
  void initState() {
    super.initState();
    _pages.add(SwipeContentPage(goals: _goals, subscriptionService: widget.subscriptionService));
    _pages.add(SavedPage(key: _savedPageKey, refreshCallback: _refreshSavedPage));
    _pages.add(PlanPage(subscriptionService: widget.subscriptionService)); // Pass the subscriptionService here
    _pages.add(MacrosPage(key: _macrosPageKey));
    _pages.add(AccountPage());
    _fetchGoals();
  }

  void _refreshSavedPage() {
    _savedPageKey.currentState?.refreshSavedRecipes();
  }

  void _refreshMacrosPage() {
    _macrosPageKey.currentState?.fetchGoalsAndConsumed();
  }

  void _onTap(int index) {
    if (index == 1) {
      _refreshSavedPage();
    } else if (index == 3) {
      _refreshMacrosPage();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _fetchGoals() async {
    final userDataDatabaseHelper = UserDataDatabaseHelper();
    final userData = await userDataDatabaseHelper.getUserData(1);
    if (userData != null) {
      final macroCalculator = MacroCalculatorService();
      final activityLevelIndex = userData.activityLevel.clamp(0, ActivityLevel.values.length - 1);
      final goalIndex = userData.goals.clamp(0, Goal.values.length - 1);
      final activityLevel = ActivityLevel.values[activityLevelIndex];
      final goal = Goal.values[goalIndex];

      final goals = macroCalculator.calculateMacros(
          userData.weight, userData.height, userData.age, userData.gender, activityLevel, goal);

      setState(() {
        _goals = goals;
        _pages[0] = SwipeContentPage(goals: _goals, subscriptionService: widget.subscriptionService);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        icons: [
          Icons.swipe,
          Icons.save,
          Icons.calendar_month,
          Icons.pie_chart,
          Icons.account_circle,
        ],
        onTap: _onTap,
        backgroundColor: AppColors.backgroundColor,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SwipeContentPage extends StatefulWidget {
  final Map<String, int> goals;
  final SubscriptionService subscriptionService;

  SwipeContentPage({required this.goals, required this.subscriptionService});

  @override
  _SwipeContentPageState createState() => _SwipeContentPageState();
}

class _SwipeContentPageState extends State<SwipeContentPage> with AutomaticKeepAliveClientMixin {
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  bool _isLoading = true;
  bool _showingReplacementDialog = false;

  @override
  void initState() {
    super.initState();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    _loadMoreCards();
  }

  Future<void> _loadMoreCards() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final random = Random();
      final int from = random.nextInt(2200);
      const int size = 50;
      const randomTag = 'under_30_minutes';
      final endpoint = 'recipes/list?from=$from&size=$size&tags=$randomTag';

      final TastyApi apiService = TastyApi();
      final data = await apiService.fetchRecipes(endpoint: endpoint);
      final List<dynamic> recipes = data['results'];

      final newItems = recipes.map((recipe) {
        final nutrition = recipe['nutrition'] ?? {};

        final macros = {
          'calories': (nutrition['calories'] ?? 0) as int,
          'protein': (nutrition['protein'] ?? 0) as int,
          'fat': (nutrition['fat'] ?? 0) as int,
          'carbohydrates': (nutrition['carbohydrates'] ?? 0) as int,
        };

        final macrosAvailable = macros.values.any((value) => value != 0);

        return SwipeItem(
          content: GestureDetector(
            onTap: () => _showExpandedCard(context, recipe),
            child: CustomCard(
              width: 400,
              height: 600,
              title: (recipe['name'] ?? 'Unknown').toString().truncateWithEllipsis(22),
              imageUrl: recipe['thumbnail_url'] ?? 'https://via.placeholder.com/300',
              imageHeight: 250,
              children: macrosAvailable && widget.goals.isNotEmpty
                  ? [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...macros.entries.map((entry) {
                      final key = entry.key == 'carbohydrates' ? 'carbs' : entry.key;
                      final unit = key == 'calories' ? '' : 'g';
                      final index = macros.keys.toList().indexOf(entry.key);
                      final goalValue = widget.goals[key == 'fat' ? 'fats' : key.toLowerCase()] ?? 1;
                      final progressValue = goalValue != 0 ? (entry.value / goalValue).clamp(0.0, 1.0) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth * 0.6;
                            return Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${key.capitalize()}: ${entry.value}$unit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: index % 2 == 0
                                      ? ProgressBar(
                                    progress: progressValue,
                                    height: 25,
                                    width: width,
                                  )
                                      : SecondaryProgressBar(
                                    progress: progressValue,
                                    height: 25,
                                    width: width,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    Text(
                      'Macros per serving',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                )
              ]
                  : [
                Text(
                  'Macros are not available for this recipe.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          likeAction: () async {
            print('Liked ${recipe['name']}');
            await _saveRecipeToDatabase(recipe);
            if (!_showingReplacementDialog) {
              _showMatchPopup(context, recipe);
            }
          },
          nopeAction: () {
            print('Nope ${recipe['name']}');
          },
        );
      }).toList();

      setState(() {
        _swipeItems.addAll(newItems);
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load more cards: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRecipeToDatabase(dynamic recipe) async {
    final savedRecipes = await RecipeDatabaseHelper().getAllRecipes();
    final userData = await UserDataDatabaseHelper().getUserData(1);
    final hasPremium = userData?.hasPremium == 1;
    final maxRecipes = hasPremium ? 1000 : 10;

    if (savedRecipes.length >= maxRecipes) {
      _showingReplacementDialog = true;
      _promptReplaceRecipe(recipe);
      return;
    }

    final ingredients = (recipe['sections'] as List<dynamic>?)
        ?.expand((section) => (section['components'] as List<dynamic>)
        .map<String>((component) {
      final ingredientName = component['ingredient']['name'];
      final measurements = component['measurements'];
      if (measurements != null && measurements.isNotEmpty) {
        final quantity = measurements[0]['quantity'];
        final unit = measurements[0]['unit']['abbreviation'];
        if (quantity == '0' || quantity == null) {
          return ingredientName;
        } else {
          return '$ingredientName: $quantity $unit';
        }
      } else {
        return ingredientName;
      }
    }))
        .toList();

    final recipeToSave = Recipe(
      name: recipe['name'] ?? 'Unknown',
      description: recipe['description'] ?? 'No description available.',
      protein: recipe['nutrition']?['protein'] ?? 0,
      calories: recipe['nutrition']?['calories'] ?? 0,
      fats: recipe['nutrition']?['fat'] ?? 0,
      carbs: recipe['nutrition']?['carbohydrates'] ?? 0,
      servings: recipe['num_servings'] ?? 1,
      ingredients: ingredients ?? [],
      instructions: (recipe['instructions'] as List<dynamic>?)
          ?.map((instruction) => instruction['display_text'].toString())
          .toList() ??
          [],
      imageUrl: recipe['thumbnail_url'] ?? 'https://via.placeholder.com/300',
    );

    await RecipeDatabaseHelper().createRecipe(recipeToSave);
  }

  Future<void> _promptReplaceRecipe(dynamic newRecipe) async {
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
                padding: EdgeInsets.only(top: 70, left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, size: 32),
                    color: AppColors.textColor,
                    onPressed: () {
                      Navigator.pop(context);
                      _showingReplacementDialog = false;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oops, it\'s a match?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your saved page is full for your current plan, subscribe to Cookr premium to get unlimited saves, access to the meal planning page, and no ads (it\'s only \$4.99 a month, and you can cancel any time).',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    PrimaryButton(
                      text: 'Upgrade',
                      onPressed: _handleUpgrade,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Or you can replace your already saved recipes below (just choose one to replace):',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
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
                      onTap: () async {
                        await RecipeDatabaseHelper().deleteRecipe(recipe.id!);
                        await _saveRecipeToDatabase(newRecipe);
                        Navigator.pop(context);
                        _showingReplacementDialog = false;
                      },
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
                          double progress = entry.value / maxValue;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleUpgrade() {
    widget.subscriptionService.buyPremiumSubscription();
  }

  void _removeCurrentCard(dynamic recipe) {
    setState(() {
      _swipeItems.removeWhere((item) {
        final card = item.content as GestureDetector;
        final customCard = card.child as CustomCard;
        return customCard.title == recipe['name'];
      });
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _logMeal(BuildContext context, dynamic recipe, Map<String, int> macros) {
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

  void _showExpandedCard(BuildContext context, dynamic recipe) {
    final nutrition = recipe['nutrition'] ?? {};
    final macros = {
      'calories': (nutrition['calories'] ?? 0) as int,
      'protein': (nutrition['protein'] ?? 0) as int,
      'fat': (nutrition['fat'] ?? 0) as int,
      'carbohydrates': (nutrition['carbohydrates'] ?? 0) as int,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SlidingPanel(
          imageUrl: recipe['thumbnail_url'] ?? 'https://via.placeholder.com/300',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '${recipe['num_servings'] ?? 'N/A'} servings',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  macros.entries.map((e) => '${e.key.capitalize()}: ${e.value}g').join(' | '),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  recipe['description'] ?? 'No description available.',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 10),
                Text(
                  'Ingredients:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ((recipe['sections'] as List<dynamic>?)?.expand<Widget>((section) {
                    return (section['components'] as List<dynamic>?)?.map<Widget>((component) {
                      final ingredientName = component['ingredient']['name'];
                      final measurements = component['measurements'];
                      if (measurements != null && measurements.isNotEmpty) {
                        final quantity = measurements[0]['quantity'];
                        final unit = measurements[0]['unit']['abbreviation'];
                        return Text(
                          quantity == '0' || quantity == null
                              ? '- $ingredientName'
                              : '- $ingredientName: $quantity $unit',
                          style: TextStyle(fontSize: 16),
                        );
                      } else {
                        return Text(
                          '- $ingredientName',
                          style: TextStyle(fontSize: 16),
                        );
                      }
                    }).toList() ?? [];
                  }).toList() ?? []),
                ),
                SizedBox(height: 10),
                Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ((recipe['instructions'] as List<dynamic>?)?.map<Widget>((instruction) {
                    return Text(
                      '- ${instruction['display_text']}',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList() ?? []),
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

  void _showMatchPopup(BuildContext context, dynamic recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopupDialog(
          title: "It's a Match!",
          content: "This recipe has been added to your saved section for you to view at any time.",
          children: [
            Image.network(
              recipe['thumbnail_url'] ?? 'https://via.placeholder.com/300',
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
          ],
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: PrimaryButton(
                      text: 'Close',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          Text(
            'Swipe',
            style: GoogleFonts.encodeSans(
              textStyle: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator(
            color: AppColors.buttonColor,
          )
              : Container(
            width: 400,
            height: 600,
            child: SwipeCards(
              matchEngine: _matchEngine,
              itemBuilder: (context, index) {
                return _swipeItems[index].content;
              },
              onStackFinished: () {
                print('Stack Finished');
                _loadMoreCards();
              },
              itemChanged: (SwipeItem item, int index) {
                print('Item changed: $index');
              },
              upSwipeAllowed: false,
              fillSpace: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
