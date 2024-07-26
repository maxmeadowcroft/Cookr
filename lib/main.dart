import 'package:cookr2/pages/swipe.dart';
import 'package:cookr2/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/user_data_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  UserDataDatabaseHelper userDataDatabaseHelper = UserDataDatabaseHelper();
  UserData? userData = await userDataDatabaseHelper.getUserData(1); // Replace with actual user ID

  bool hasSeenWelcome = userData?.hasSeenWelcome == 1;

  runApp(MyApp(hasSeenWelcome: hasSeenWelcome));
}

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;

  MyApp({required this.hasSeenWelcome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasty Recipes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: hasSeenWelcome ? SwipePage() : WelcomePage(),
    );
  }
}
