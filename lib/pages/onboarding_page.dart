import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/user_data_database_helper.dart';
import 'swipe.dart';
import '../util/colors.dart'; // Ensure this import points to the correct file
import '../components/primary_button.dart'; // Adjust the import path if necessary
import '../services/subscriptions.dart'; // Import the SubscriptionService

class OnboardingPage extends StatefulWidget {
  final SubscriptionService subscriptionService; // Add this line

  OnboardingPage({required this.subscriptionService}); // Add this line

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  int _weight = 0;
  int _height = 0;
  int _age = 0;
  String _gender = '';
  int _activityLevel = 1; // Default to "Moderately active"
  int _goal = 1; // Default to "Maintain weight"

  void _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      UserData newUser = UserData(
        weight: _weight,
        height: _height,
        age: _age,
        gender: _gender,
        activityLevel: _activityLevel,
        seenRecipes: 0,
        cookedRecipes: 0,
        hasPremium: 0,
        goals: _goal,
        hasSeenWelcome: 1,
      );

      await UserDataDatabaseHelper().createUserData(newUser);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SwipePage(subscriptionService: widget.subscriptionService), // Pass the subscriptionService
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Onboarding',
          style: GoogleFonts.encodeSans(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  _weight = int.parse(value);
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  _height = int.parse(value);
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  _age = int.parse(value);
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your gender';
                  }
                  _gender = value;
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _activityLevel,
                decoration: InputDecoration(labelText: 'Activity Level'),
                items: [
                  DropdownMenuItem(value: 0, child: Text('Not very active')),
                  DropdownMenuItem(value: 1, child: Text('Moderately active')),
                  DropdownMenuItem(value: 2, child: Text('Active')),
                ],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _goal,
                decoration: InputDecoration(labelText: 'Goal'),
                items: [
                  DropdownMenuItem(value: 0, child: Text('Lose weight')),
                  DropdownMenuItem(value: 1, child: Text('Maintain weight')),
                  DropdownMenuItem(value: 2, child: Text('Gain muscle')),
                ],
                onChanged: (value) {
                  setState(() {
                    _goal = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              PrimaryButton(
                text: 'Save',
                onPressed: _saveUserData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
