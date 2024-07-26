import 'package:cookr2/services/subscriptions.dart';
import 'package:cookr2/services/tasty_api.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  final SubscriptionService subscriptionService = SubscriptionService();
  subscriptionService.init();
  runApp(MyApp(subscriptionService: subscriptionService));
}

class MyApp extends StatelessWidget {
  final SubscriptionService subscriptionService;

  MyApp({required this.subscriptionService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasty Recipes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeScreen(subscriptionService: subscriptionService),
    );
  }
}

class RecipeScreen extends StatefulWidget {
  final SubscriptionService subscriptionService;

  RecipeScreen({required this.subscriptionService});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TastyApi api = TastyApi();
  List<dynamic> recipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCachedRecipes();
  }

  Future<void> fetchCachedRecipes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await api.fetchRecipes();
      setState(() {
        recipes = data['results'];
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchNewRecipes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await api.fetchRandomRecipes();
      setState(() {
        recipes = data['results'];
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasty Recipes'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipe['thumbnail_url'] != null)
                    Image.network(recipe['thumbnail_url']),
                  SizedBox(height: 8.0),
                  Text(
                    recipe['name'] ?? 'No name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(recipe['description'] ?? 'No description'),
                  SizedBox(height: 8.0),
                  if (recipe['nutrition'] != null) ...[
                    Text('Calories: ${recipe['nutrition']['calories'] ?? 'N/A'}'),
                    Text('Protein: ${recipe['nutrition']['protein'] ?? 'N/A'}g'),
                    Text('Fats: ${recipe['nutrition']['fat'] ?? 'N/A'}g'),
                    Text('Carbs: ${recipe['nutrition']['carbohydrates'] ?? 'N/A'}g'),
                  ],
                  SizedBox(height: 8.0),
                  Text('Servings: ${recipe['num_servings'] ?? 'N/A'}'),
                  SizedBox(height: 8.0),
                  if (recipe['sections'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingredients:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipe['sections'].map<Widget>((section) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: section['components'].map<Widget>((component) {
                              return Text(component['raw_text']);
                            }).toList(),
                          );
                        }).toList(),
                      ],
                    ),
                  SizedBox(height: 8.0),
                  if (recipe['instructions'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipe['instructions'].map<Widget>((instruction) {
                          return Text('${instruction['position']}. ${instruction['display_text']}');
                        }).toList(),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: fetchNewRecipes,
          child: Text('Get New Recipes'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.subscriptionService.buyPremiumSubscription();
          setState(() {});
        },
        child: Icon(Icons.star),
      ),
    );
  }
}
