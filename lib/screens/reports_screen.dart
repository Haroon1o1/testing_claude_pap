import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  UserProfile _profile = UserProfile.defaultProfile();
  List<WeightEntry> _weightEntries = [];
  List<DailyActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _loadData();
  }

  void _loadData() async {
    final profile = await DataManager.getProfile();
    final w = await DataManager.getWeightEntries();
    final a = await DataManager.getActivities();
    setState(() {
      _profile = profile;
      _weightEntries = w;
      _activities = a;
    });
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  List<DailyActivity> get _last7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _activities.where((a) => a.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Reports', style: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHealthScore(),
            const SizedBox(height: 20),
            _buildWeeklyReport(),
            const SizedBox(height: 20),
            _buildBodyMetrics(),
            const SizedBox(height: 20),
            _buildGoalProgress(),
            const SizedBox(height: 20),
            _buildInsights(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore() {
    final score = _calculateHealthScore();

    return AnimatedBuilder(
      animation: _entryController,
      builder: (_, child) => FadeTransition(
        opacity: _entryController,
        child: child,
      ),
      child: GradientCard(
        gradient: AppColors.primaryGradient,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Score', style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$score', style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900,
                        height: 1)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text('/100', style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_getHealthMessage(score), style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: 60,
              lineWidth: 12,
              percent: score / 100,
              center: Icon(
                score >= 80 ? Icons.sentiment_very_satisfied_rounded
                    : score >= 60 ? Icons.sentiment_satisfied_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                color: Colors.white, size: 32,
              ),
              progressColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateHealthScore() {
    int score = 50;
    if (_profile.bmi >= 18.5 && _profile.bmi <= 24.9) score += 15;
    else if (_profile.bmi > 0) score += 5;

    final acts = _last7Days;
    if (acts.isNotEmpty) {
      final avgSteps = acts.map((a) => a.steps).reduce((a, b) => a + b) / acts.length;
      final targetSteps = _profile.targetSteps ?? 10000;
      score += ((avgSteps / targetSteps) * 20).clamp(0, 20).toInt();

      final avgSleep = acts.map((a) => a.sleepMinutes).reduce((a, b) => a + b) / acts.length;
      if (avgSleep >= 420) score += 10; else if (avgSleep >= 360) score += 5;

      final avgWater = acts.map((a) => a.waterMl).reduce((a, b) => a + b) / acts.length;
      final targetWater = _profile.targetWaterMl ?? 2500;
      score += ((avgWater / targetWater) * 5).clamp(0, 5).toInt();
    }
    return score.clamp(0, 100);
  }

  String _getHealthMessage(int score) {
    if (score >= 80) return 'Excellent! Keep it up, champion!';
    if (score >= 60) return 'Good progress! Push a bit harder!';
    return 'Room to grow! Let\'s level up!';
  }

  Widget _buildWeeklyReport() {
    final acts = _last7Days;
    final totalSteps = acts.isEmpty ? 0 : acts.map((a) => a.steps).reduce((a, b) => a + b);
    final totalCal = acts.isEmpty ? 0 : acts.map((a) => a.caloriesBurned).reduce((a, b) => a + b).toInt();
    final avgSleep = acts.isEmpty ? 0.0 : acts.map((a) => a.sleepMinutes).reduce((a, b) => a + b) / acts.length / 60;
    final avgWater = acts.isEmpty ? 0 : (acts.map((a) => a.waterMl).reduce((a, b) => a + b) / acts.length).toInt();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_view_week_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Weekly Summary', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildReportMetric('Total Steps', '$totalSteps', Icons.directions_walk_rounded, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildReportMetric('Calories', '${totalCal}kcal', Icons.local_fire_department_rounded, AppColors.accentOrange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildReportMetric('Avg Sleep', '${avgSleep.toStringAsFixed(1)}h', Icons.bedtime_rounded, const Color(0xFF764BA2))),
              const SizedBox(width: 12),
              Expanded(child: _buildReportMetric('Avg Water', '${(avgWater / 1000).toStringAsFixed(1)}L', Icons.water_drop_rounded, AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(label, style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetrics() {
    final bmi = _profile.bmi;
    Color bmiColor = AppColors.success;
    String bmiCategory = _profile.bmiCategory;
    if (bmiCategory == 'Underweight') bmiColor = AppColors.warning;
    if (bmiCategory == 'Overweight') bmiColor = AppColors.accentOrange;
    if (bmiCategory == 'Obese') bmiColor = AppColors.error;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Body Metrics', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricRow('Weight', '${_profile.currentWeight?.toStringAsFixed(1) ?? "--"} kg', AppColors.primary),
          const Divider(height: 24, color: AppColors.surfaceSecondary),
          _buildMetricRow('Height', '${_profile.currentHeight?.toStringAsFixed(0) ?? "--"} cm', AppColors.accent),
          const Divider(height: 24, color: AppColors.surfaceSecondary),
          _buildMetricRow('BMI', bmi.toStringAsFixed(1), bmiColor, suffix: bmiCategory),
          const Divider(height: 24, color: AppColors.surfaceSecondary),
          _buildMetricRow('Goal Weight', '${_profile.goalWeight?.toStringAsFixed(1) ?? "--"} kg', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color, {String? suffix}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(
          fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Text(value, style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            if (suffix != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(suffix, style: GoogleFonts.poppins(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildGoalProgress() {
    final weightGoal = _profile.goalWeight;
    final currentWeight = _profile.currentWeight;
    double weightProgress = 0;
    if (weightGoal != null && currentWeight != null && _weightEntries.isNotEmpty) {
      final startWeight = _weightEntries.first.weight;
      if (startWeight != weightGoal) {
        weightProgress = ((startWeight - currentWeight) / (startWeight - weightGoal)).clamp(0.0, 1.0);
      }
    }

    final acts = _last7Days;
    double stepsProgress = 0;
    if (acts.isNotEmpty) {
      final avg = acts.map((a) => a.steps).reduce((a, b) => a + b) / acts.length;
      stepsProgress = (avg / (_profile.targetSteps ?? 10000)).clamp(0.0, 1.0);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.warmGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Goal Progress', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar('Weight Goal', weightProgress, AppColors.primary),
          const SizedBox(height: 16),
          _buildProgressBar('Daily Steps', stepsProgress, AppColors.accentOrange),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 10,
          percent: progress,
          backgroundColor: color.withOpacity(0.1),
          progressColor: color,
          barRadius: const Radius.circular(10),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 1200,
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final insights = _generateInsights();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('AI Insights', style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: insight['color'] as Color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(insight['text'] as String, style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights() {
    final insights = <Map<String, dynamic>>[];
    final acts = _last7Days;

    if (acts.isNotEmpty) {
      final avgSteps = acts.map((a) => a.steps).reduce((a, b) => a + b) / acts.length;
      final target = _profile.targetSteps ?? 10000;
      if (avgSteps < target * 0.7) {
        insights.add({'text': 'Your step count is below target. Try a 20-min walk daily to boost activity.', 'color': AppColors.warning});
      } else {
        insights.add({'text': 'Great job hitting your step goals this week! Consistency is key.', 'color': AppColors.success});
      }

      final avgSleep = acts.map((a) => a.sleepMinutes).reduce((a, b) => a + b) / acts.length;
      if (avgSleep < 420) {
        insights.add({'text': 'You\'re averaging under 7 hours of sleep. Aim for 7-9 hours for optimal recovery.', 'color': AppColors.accentOrange});
      } else {
        insights.add({'text': 'Your sleep schedule looks healthy. Quality sleep fuels athletic performance.', 'color': AppColors.success});
      }

      final avgWater = acts.map((a) => a.waterMl).reduce((a, b) => a + b) / acts.length;
      if (avgWater < (_profile.targetWaterMl ?? 2500) * 0.8) {
        insights.add({'text': 'Hydration is low. Drink water regularly throughout the day for peak performance.', 'color': AppColors.accent});
      }
    }

    if (_profile.bmi > 0) {
      if (_profile.bmiCategory == 'Normal') {
        insights.add({'text': 'Your BMI is in the healthy range. Keep maintaining your current lifestyle!', 'color': AppColors.success});
      } else {
        insights.add({'text': 'Focus on balanced nutrition and consistent exercise to reach your ideal weight.', 'color': AppColors.primary});
      }
    }

    return insights;
  }
}
