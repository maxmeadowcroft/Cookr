enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive, extraActive }
enum Goal { loseWeight, gainMuscle, maintainWeight }

class MacroCalculatorService {
  int calculateCalories(int weight, int heightCm, int age, String gender, ActivityLevel activityLevel, Goal goal) {
    double weightKg = weight / 2.205;
    double bmr;

    print('Weight (kg): $weightKg');
    print('Height (cm): $heightCm');

    // BMR calculation using Mifflin-St Jeor Equation
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }

    print('BMR: $bmr');

    double activityMultiplier = _getActivityMultiplier(activityLevel);
    print('Activity Multiplier: $activityMultiplier');

    double tdee = bmr * activityMultiplier;
    print('TDEE before goal adjustment: $tdee');

    double adjustedTdee = _applyGoalAdjustment(tdee, goal);
    print('Adjusted TDEE: $adjustedTdee');

    return adjustedTdee.round();
  }

  int calculateProtein(int weight) {
    int protein = (weight * 0.8).round();
    print('Protein (g): $protein');
    return protein;
  }

  int calculateFats(int totalCalories) {
    int fats = ((totalCalories * 0.25) / 9).round();
    print('Fats (g): $fats');
    return fats;
  }

  int calculateCarbs(int totalCalories, int protein, int fats) {
    int proteinCalories = protein * 4;
    int fatCalories = fats * 9;
    int remainingCalories = totalCalories - (proteinCalories + fatCalories);
    int carbs = (remainingCalories / 4).round();
    print('Carbs (g): $carbs');
    return carbs;
  }

  double _getActivityMultiplier(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.3; // Adjusted from 1.375
      case ActivityLevel.moderatelyActive:
        return 1.5; // Adjusted from 1.55
      case ActivityLevel.veryActive:
        return 1.7; // Adjusted from 1.725
      case ActivityLevel.extraActive:
        return 1.9;
      default:
        return 1.0;
    }
  }

  double _applyGoalAdjustment(double tdee, Goal goal) {
    switch (goal) {
      case Goal.loseWeight:
        return tdee * 0.9;  // 10% reduction
      case Goal.gainMuscle:
        return tdee * 1.1;  // 10% increase
      case Goal.maintainWeight:
        return tdee;  // no change
      default:
        return tdee;
    }
  }

  Map<String, int> calculateMacros(int weight, int heightCm, int age, String gender, ActivityLevel activityLevel, Goal goal) {
    int calories = calculateCalories(weight, heightCm, age, gender, activityLevel, goal);
    int protein = calculateProtein(weight);
    int fats = calculateFats(calories);
    int carbs = calculateCarbs(calories, protein, fats);

    return {
      'calories': calories,
      'protein': protein,
      'fats': fats,
      'carbs': carbs,
    };
  }
}
