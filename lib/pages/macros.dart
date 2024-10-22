import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../components/primary_progress_bar.dart';
import '../components/secondary_progress_bar.dart';
import '../components/primary_button.dart';
import '../util/colors.dart';
import '../database/user_data_database_helper.dart';
import '../database/database_helper.dart';
import '../services/macro_calculator_service.dart';

class MacrosPage extends StatefulWidget {
  final Function? onRefresh;
  const MacrosPage({super.key, this.onRefresh});

  @override
  MacrosPageState createState() => MacrosPageState();
}

class MacrosPageState extends State<MacrosPage> {
  bool _isLoading = true;
  Map<String, int> _goals = {};
  Map<String, int> _consumed = {
    'calories': 0,
    'protein': 0,
    'fats': 0,
    'carbs': 0,
  };
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchGoalsAndConsumed();
    _resetOldestEntry();
  }

  Future<void> fetchGoalsAndConsumed() async {
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

      final dbHelper = DatabaseHelper.instance;
      final consumedData = await dbHelper.getLast10DaysData();
      final consumed = _extractConsumedMacros(consumedData, _selectedDate);

      setState(() {
        _goals = goals;
        _consumed = consumed;
        _isLoading = false;
      });
    }
  }

  Map<String, int> _extractConsumedMacros(List<Map<String, dynamic>> data, DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final entry = data.firstWhere((element) => element['date'] == dateString, orElse: () => {});
    return {
      'calories': entry['calories'] ?? 0,
      'protein': entry['protein'] ?? 0,
      'fats': entry['fats'] ?? 0,
      'carbs': entry['carbs'] ?? 0,
    };
  }

  Future<void> _logMacros() async {
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController proteinController = TextEditingController();
    final TextEditingController fatsController = TextEditingController();
    final TextEditingController carbsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Log Macros",
            style: TextStyle(color: AppColors.textColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: "Calories", labelStyle: TextStyle(color: AppColors.textColor)),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: proteinController,
                  decoration: const InputDecoration(labelText: "Protein", labelStyle: TextStyle(color: AppColors.textColor)),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fatsController,
                  decoration: const InputDecoration(labelText: "Fats", labelStyle: TextStyle(color: AppColors.textColor)),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: carbsController,
                  decoration: const InputDecoration(labelText: "Carbs", labelStyle: TextStyle(color: AppColors.textColor)),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: AppColors.buttonColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Log", style: TextStyle(color: AppColors.buttonColor)),
              onPressed: () async {
                final dbHelper = DatabaseHelper.instance;
                await dbHelper.logMacros(
                  _selectedDate,
                  _consumed['calories']! + (int.tryParse(caloriesController.text) ?? 0),
                  _consumed['protein']! + (int.tryParse(proteinController.text) ?? 0),
                  _consumed['fats']! + (int.tryParse(fatsController.text) ?? 0),
                  _consumed['carbs']! + (int.tryParse(carbsController.text) ?? 0),
                );
                Navigator.of(context).pop();
                await fetchGoalsAndConsumed();
                if (widget.onRefresh != null) widget.onRefresh!(); // Call the callback if available
              },
            ),
          ],
          backgroundColor: AppColors.backgroundColor,
        );
      },
    );
  }

  Future<void> _resetOldestEntry() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.resetOldestEntry();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 10)),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonColor,
              onPrimary: Colors.white,
              surface: AppColors.backgroundColor,
              onSurface: AppColors.textColor,
            ),
            dialogBackgroundColor: AppColors.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await fetchGoalsAndConsumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Macros',
                      style: GoogleFonts.encodeSans(
                        textStyle: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(30.0), // High border radius for oval shape
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                DateFormat.E().format(_selectedDate),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0), // Adjusted padding for top and bottom
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                DateFormat.d().format(_selectedDate),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildMacroProgress('Calories', 'calories', _goals['calories']!, _consumed['calories']!, true),
              _buildMacroProgress('Protein', 'protein', _goals['protein']!, _consumed['protein']!, false, true),
              _buildMacroProgress('Fats', 'fats', _goals['fats']!, _consumed['fats']!, true, true),
              _buildMacroProgress('Carbs', 'carbs', _goals['carbs']!, _consumed['carbs']!, false, true),
              const SizedBox(height: 20),
              Center(
                child: PrimaryButton(
                  text: 'Log Macros',
                  onPressed: () {
                    _logMacros();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Remaining: $remaining$unit',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth; // Use 100% of the available width
            return usePrimary
                ? ProgressBar(
              progress: progress,
              height: 25,
              width: width,
            )
                : SecondaryProgressBar(
              progress: progress,
              height: 25,
              width: width,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
