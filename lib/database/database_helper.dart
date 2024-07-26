class UserData {
  final int? id;
  final int activityLevel;
  final int seenRecipes;
  final int cookedRecipes;
  final int hasPremium;
  final int goals;
  final int hasSeenWelcome;

  UserData({
    this.id,
    required this.activityLevel,
    required this.seenRecipes,
    required this.cookedRecipes,
    required this.hasPremium,
    required this.goals,
    required this.hasSeenWelcome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_level': activityLevel,
      'seen_recipes': seenRecipes,
      'cooked_recipes': cookedRecipes,
      'has_premium': hasPremium,
      'goals': goals,
      'has_seen_welcome': hasSeenWelcome,
    };
  }

  static UserData fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      activityLevel: map['activity_level'],
      seenRecipes: map['seen_recipes'],
      cookedRecipes: map['cooked_recipes'],
      hasPremium: map['has_premium'],
      goals: map['goals'],
      hasSeenWelcome: map['has_seen_welcome'],
    );
  }
}
