import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';

class DataManager {
  static const String _weightKey = 'weight_entries';
  static const String _heightKey = 'height_entries';
  static const String _profileKey = 'user_profile';
  static const String _activitiesKey = 'daily_activities';

  static Future<List<WeightEntry>> getWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_weightKey);
    if (data == null) return _generateSampleWeightData();
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => WeightEntry.fromJson(e)).toList();
  }

  static Future<void> saveWeightEntry(WeightEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getWeightEntries();
    entries.removeWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    entries.add(entry);
    entries.sort((a, b) => a.date.compareTo(b.date));
    await prefs.setString(_weightKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  static Future<List<HeightEntry>> getHeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_heightKey);
    if (data == null) return _generateSampleHeightData();
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => HeightEntry.fromJson(e)).toList();
  }

  static Future<void> saveHeightEntry(HeightEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getHeightEntries();
    entries.removeWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    entries.add(entry);
    entries.sort((a, b) => a.date.compareTo(b.date));
    await prefs.setString(_heightKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data == null) return UserProfile.defaultProfile();
    return UserProfile.fromJson(jsonDecode(data));
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<List<DailyActivity>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_activitiesKey);
    if (data == null) return _generateSampleActivityData();
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => DailyActivity.fromJson(e)).toList();
  }

  static Future<void> saveActivity(DailyActivity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();
    activities.removeWhere((e) =>
        e.date.year == activity.date.year &&
        e.date.month == activity.date.month &&
        e.date.day == activity.date.day);
    activities.add(activity);
    activities.sort((a, b) => a.date.compareTo(b.date));
    await prefs.setString(_activitiesKey, jsonEncode(activities.map((e) => e.toJson()).toList()));
  }

  static List<WeightEntry> _generateSampleWeightData() {
    final now = DateTime.now();
    final weights = [75.2, 74.8, 74.5, 74.1, 73.8, 73.5, 73.2, 72.9, 72.7, 72.4, 72.1, 71.8];
    return List.generate(weights.length, (i) => WeightEntry(
      date: now.subtract(Duration(days: (weights.length - 1 - i) * 7)),
      weight: weights[i],
    ));
  }

  static List<HeightEntry> _generateSampleHeightData() {
    final now = DateTime.now();
    return [HeightEntry(date: now, height: 175.0)];
  }

  static List<DailyActivity> _generateSampleActivityData() {
    final now = DateTime.now();
    return List.generate(14, (i) {
      final d = now.subtract(Duration(days: 13 - i));
      return DailyActivity(
        date: d,
        steps: 6000 + (i * 300) % 4000,
        caloriesBurned: 250 + (i * 50) % 400,
        waterMl: 1500 + (i * 200) % 1200,
        sleepMinutes: 360 + (i * 30) % 120,
        workoutMinutes: 20 + (i * 10) % 40,
      );
    });
  }
}
