import 'package:flutter/material.dart';
import '../database/user_data_database_helper.dart';
import 'swipe.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Tasty Recipes!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Discover new and delicious recipes tailored to your preferences.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  UserDataDatabaseHelper userDataDatabaseHelper = UserDataDatabaseHelper();
                  UserData? userData = await userDataDatabaseHelper.getUserData(1); // Replace with actual user ID

                  if (userData != null) {
                    UserData updatedUser = UserData(
                      id: userData.id,
                      activityLevel: userData.activityLevel,
                      seenRecipes: userData.seenRecipes,
                      cookedRecipes: userData.cookedRecipes,
                      hasPremium: userData.hasPremium,
                      goals: userData.goals,
                      hasSeenWelcome: 1,
                    );

                    await userDataDatabaseHelper.updateUserData(updatedUser);
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SwipePage()),
                  );
                },
                child: Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
