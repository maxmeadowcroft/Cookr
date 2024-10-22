import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/user_data_database_helper.dart';
import '../util/colors.dart';
import '../components/secondary_button.dart';
import '../components/primary_button.dart';
import 'edit_account.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<UserData?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = UserDataDatabaseHelper().getUserData(1); // Assume user ID is 1 for now
  }

  void _updateUserData(UserData updatedUser) {
    setState(() {
      _userDataFuture = Future.value(updatedUser);
    });
  }

  Future<void> _togglePremiumStatus() async {
    final userData = await UserDataDatabaseHelper().getUserData(1);
    if (userData != null) {
      final updatedUser = userData.copyWith(hasPremium: userData.hasPremium == 1 ? 0 : 1);
      await UserDataDatabaseHelper().updateUserData(updatedUser);
      _updateUserData(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<UserData?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No user data found.'));
          } else {
            final userData = snapshot.data!;
            final heightFeetInches = _convertCmToFeetInches(userData.height);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      'Account',
                      style: GoogleFonts.encodeSans(
                        textStyle: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('Weight:', '${userData.weight} lbs'),
                    const SizedBox(height: 10),
                    _buildInfoRow('Height:', heightFeetInches),
                    const SizedBox(height: 10),
                    _buildInfoRow('Age:', '${userData.age} years'),
                    const SizedBox(height: 10),
                    _buildInfoRow('Gender:', userData.gender),
                    const SizedBox(height: 10),
                    _buildInfoRow('Activity Level:', _activityLevelToString(userData.activityLevel)),
                    const SizedBox(height: 10),
                    _buildInfoRow('Goal:', _goalToString(userData.goals)),
                    const SizedBox(height: 10),
                    _buildInfoRow('Recipes Seen:', '${userData.seenRecipes}'),
                    const SizedBox(height: 10),
                    _buildInfoRow('Recipes Cooked:', '${userData.cookedRecipes}'),
                    const SizedBox(height: 20),
                    SecondaryButton(
                      text: 'Edit',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAccountPage(
                              userData: userData,
                              onSave: _updateUserData,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      text: userData.hasPremium == 1 ? 'Downgrade from Premium' : 'Upgrade to Premium',
                      onPressed: _togglePremiumStatus,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _convertCmToFeetInches(int cm) {
    double inches = cm / 2.54;
    int feet = inches ~/ 12;
    int remainingInches = (inches % 12).round();
    return '$feet\' $remainingInches"';
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.encodeSans(
          textStyle: const TextStyle(
            fontSize: 20,
            color: AppColors.textColor,
          ),
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' $value',
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  String _activityLevelToString(int activityLevel) {
    switch (activityLevel) {
      case 0:
        return 'Sedentary';
      case 1:
        return 'Lightly Active';
      case 2:
        return 'Moderately Active';
      case 3:
        return 'Very Active';
      case 4:
        return 'Extra Active';
      default:
        return 'Unknown';
    }
  }

  String _goalToString(int goal) {
    switch (goal) {
      case 0:
        return 'Lose Weight';
      case 1:
        return 'Maintain Weight';
      case 2:
        return 'Gain Muscle';
      default:
        return 'Unknown';
    }
  }
}
