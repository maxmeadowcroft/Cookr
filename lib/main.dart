import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:google_fonts/google_fonts.dart';
import 'pages/swipe.dart'; // Correct path to SwipePage
import 'pages/welcome_page.dart';
import 'database/database_helper.dart';
import 'database/user_data_database_helper.dart';
import 'services/subscriptions.dart'; // Import the SubscriptionService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DatabaseHelper.instance.database;

  UserDataDatabaseHelper userDataDatabaseHelper = UserDataDatabaseHelper();
  UserData? userData = await userDataDatabaseHelper.getUserData(1); // Replace with actual user ID

  bool hasSeenWelcome = userData?.hasSeenWelcome == 1;

  SubscriptionService subscriptionService = SubscriptionService(); // Initialize the subscription service

  runApp(MyApp(hasSeenWelcome: hasSeenWelcome, subscriptionService: subscriptionService));
}

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;
  final SubscriptionService subscriptionService;

  MyApp({required this.hasSeenWelcome, required this.subscriptionService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasty Recipes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.encodeSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: hasSeenWelcome
          ? SwipePage(subscriptionService: subscriptionService)
          : WelcomePage(subscriptionService: subscriptionService),
    );
  }
}
