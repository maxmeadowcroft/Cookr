import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/user_data_database_helper.dart';
import '../util/colors.dart';
import '../components/primary_button.dart';

class EditAccountPage extends StatefulWidget {
  final UserData userData;
  final Function(UserData) onSave;

  const EditAccountPage({
    Key? key,
    required this.userData,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late int _weight;
  late int _heightFeet;
  late int _heightInches;
  late int _age;
  late String _gender;
  late int _activityLevel;
  late int _goal;

  @override
  void initState() {
    super.initState();
    _weight = widget.userData.weight;
    int totalInches = (widget.userData.height * 0.393701).round();
    _heightFeet = totalInches ~/ 12;
    _heightInches = totalInches % 12;
    _age = widget.userData.age;
    _gender = widget.userData.gender.toLowerCase();
    _activityLevel = widget.userData.activityLevel;
    _goal = widget.userData.goals;
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      int heightCm = ((_heightFeet * 12 + _heightInches) * 2.54).round();

      final updatedUserData = UserData(
        id: widget.userData.id,
        weight: _weight,
        height: heightCm,
        age: _age,
        gender: _gender,
        activityLevel: _activityLevel,
        seenRecipes: widget.userData.seenRecipes,
        cookedRecipes: widget.userData.cookedRecipes,
        hasPremium: widget.userData.hasPremium,
        goals: _goal,
        hasSeenWelcome: widget.userData.hasSeenWelcome,
      );

      await UserDataDatabaseHelper().updateUserData(updatedUserData);
      widget.onSave(updatedUserData);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Account',
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
                initialValue: _weight.toString(),
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
                onSaved: (value) {
                  _weight = int.parse(value!);
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _heightFeet.toString(),
                      decoration: InputDecoration(labelText: 'Height (ft)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter feet';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _heightFeet = int.parse(value!);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: _heightInches.toString(),
                      decoration: InputDecoration(labelText: 'Height (in)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter inches';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _heightInches = int.parse(value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: _age.toString(),
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value!);
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                dropdownColor: AppColors.backgroundColor,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _activityLevel,
                decoration: InputDecoration(labelText: 'Activity Level'),
                items: [
                  DropdownMenuItem(value: 0, child: Text('Sedentary')),
                  DropdownMenuItem(value: 1, child: Text('Lightly Active')),
                  DropdownMenuItem(value: 2, child: Text('Moderately Active')),
                  DropdownMenuItem(value: 3, child: Text('Very Active')),
                  DropdownMenuItem(value: 4, child: Text('Extra Active')),
                ],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
                dropdownColor: AppColors.backgroundColor,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _goal,
                decoration: InputDecoration(labelText: 'Goal'),
                items: [
                  DropdownMenuItem(value: 0, child: Text('Lose Weight')),
                  DropdownMenuItem(value: 1, child: Text('Maintain Weight')),
                  DropdownMenuItem(value: 2, child: Text('Gain Muscle')),
                ],
                onChanged: (value) {
                  setState(() {
                    _goal = value!;
                  });
                },
                dropdownColor: AppColors.backgroundColor,
              ),
              SizedBox(height: 20),
              PrimaryButton(
                text: 'Save',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
