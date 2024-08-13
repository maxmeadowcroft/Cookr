import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_page.dart'; // Import the onboarding page
import '../util/colors.dart'; // Ensure this import points to the correct file
import '../components/primary_button.dart'; // Adjust the import path if necessary
import '../services/subscriptions.dart'; // Import the SubscriptionService

class WelcomePage extends StatelessWidget {
  final SubscriptionService subscriptionService;

  WelcomePage({required this.subscriptionService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Set the background color here
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to',
                style: GoogleFonts.encodeSans(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: AppColors.textColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Cookr',
                style: GoogleFonts.encodeSans(
                  textStyle: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Thank you for downloading',
                style: GoogleFonts.encodeSans(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              SizedBox(height: 40),
              PrimaryButton(
                text: 'Start Finding Recipes',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnboardingPage(
                        subscriptionService: subscriptionService,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 40)
            ],
          ),
        ),
      ),
    );
  }
}
