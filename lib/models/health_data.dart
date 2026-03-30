class WeightEntry {
  final DateTime date;
  final double weight; // in kg
  final String? note;

  WeightEntry({required this.date, required this.weight, this.note});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight': weight,
        'note': note,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        date: DateTime.parse(json['date']),
        weight: json['weight'].toDouble(),
        note: json['note'],
      );
}

class HeightEntry {
  final DateTime date;
  final double height; // in cm

  HeightEntry({required this.date, required this.height});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'height': height,
      };

  factory HeightEntry.fromJson(Map<String, dynamic> json) => HeightEntry(
        date: DateTime.parse(json['date']),
        height: json['height'].toDouble(),
      );
}

class UserProfile {
  String name;
  int age;
  String gender;
  String avatarPath;
  double? currentWeight;
  double? currentHeight;
  double? goalWeight;
  double? targetCalories;
  int? targetSteps;
  int? targetWaterMl;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    this.avatarPath = '',
    this.currentWeight,
    this.currentHeight,
    this.goalWeight,
    this.targetCalories,
    this.targetSteps,
    this.targetWaterMl,
  });

  double get bmi {
    if (currentWeight == null || currentHeight == null || currentHeight == 0) return 0;
    double heightM = currentHeight! / 100;
    return currentWeight! / (heightM * heightM);
  }

  String get bmiCategory {
    double b = bmi;
    if (b == 0) return 'N/A';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'avatarPath': avatarPath,
        'currentWeight': currentWeight,
        'currentHeight': currentHeight,
        'goalWeight': goalWeight,
        'targetCalories': targetCalories,
        'targetSteps': targetSteps,
        'targetWaterMl': targetWaterMl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? 'Athlete',
        age: json['age'] ?? 25,
        gender: json['gender'] ?? 'Male',
        avatarPath: json['avatarPath'] ?? '',
        currentWeight: json['currentWeight']?.toDouble(),
        currentHeight: json['currentHeight']?.toDouble(),
        goalWeight: json['goalWeight']?.toDouble(),
        targetCalories: json['targetCalories']?.toDouble(),
        targetSteps: json['targetSteps'],
        targetWaterMl: json['targetWaterMl'],
      );

  static UserProfile defaultProfile() => UserProfile(
        name: 'Athlete',
        age: 25,
        gender: 'Male',
        currentWeight: 70.0,
        currentHeight: 175.0,
        goalWeight: 65.0,
        targetCalories: 2000,
        targetSteps: 10000,
        targetWaterMl: 2500,
      );
}

class DailyActivity {
  final DateTime date;
  int steps;
  double caloriesBurned;
  int waterMl;
  int sleepMinutes;
  double workoutMinutes;

  DailyActivity({
    required this.date,
    this.steps = 0,
    this.caloriesBurned = 0,
    this.waterMl = 0,
    this.sleepMinutes = 0,
    this.workoutMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'steps': steps,
        'caloriesBurned': caloriesBurned,
        'waterMl': waterMl,
        'sleepMinutes': sleepMinutes,
        'workoutMinutes': workoutMinutes,
      };

  factory DailyActivity.fromJson(Map<String, dynamic> json) => DailyActivity(
        date: DateTime.parse(json['date']),
        steps: json['steps'] ?? 0,
        caloriesBurned: json['caloriesBurned']?.toDouble() ?? 0,
        waterMl: json['waterMl'] ?? 0,
        sleepMinutes: json['sleepMinutes'] ?? 0,
        workoutMinutes: json['workoutMinutes']?.toDouble() ?? 0,
      );
}
