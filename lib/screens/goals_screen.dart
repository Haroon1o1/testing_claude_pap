import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import '../widgets/glass_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  UserProfile _profile = UserProfile.defaultProfile();

  final _weightGoalController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  final _waterController = TextEditingController();
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _loadData();
  }

  void _loadData() async {
    final profile = await DataManager.getProfile();
    setState(() {
      _profile = profile;
      _weightGoalController.text = profile.goalWeight?.toStringAsFixed(1) ?? '';
      _caloriesController.text = profile.targetCalories?.toStringAsFixed(0) ?? '';
      _stepsController.text = profile.targetSteps?.toString() ?? '';
      _waterController.text = profile.targetWaterMl?.toString() ?? '';
    });
    _entryController.forward();
  }

  Future<void> _saveGoals() async {
    _profile.goalWeight = double.tryParse(_weightGoalController.text);
    _profile.targetCalories = double.tryParse(_caloriesController.text);
    _profile.targetSteps = int.tryParse(_stepsController.text);
    _profile.targetWaterMl = int.tryParse(_waterController.text);
    await DataManager.saveProfile(_profile);
    setState(() => _editMode = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Goals updated!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _weightGoalController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Set Goals', style: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_editMode) _saveGoals();
              else setState(() => _editMode = true);
            },
            icon: Icon(_editMode ? Icons.check_rounded : Icons.edit_rounded,
              color: AppColors.primary),
            label: Text(_editMode ? 'Save' : 'Edit', style: GoogleFonts.poppins(
              color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMotivationBanner(),
            const SizedBox(height: 24),
            _buildGoalCard(
              title: 'Weight Goal',
              subtitle: 'Target body weight',
              icon: Icons.monitor_weight_rounded,
              gradient: AppColors.primaryGradient,
              controller: _weightGoalController,
              unit: 'kg',
              current: _profile.currentWeight,
              goal: _profile.goalWeight,
              currentLabel: 'Current',
              goalLabel: 'Target',
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              title: 'Daily Steps',
              subtitle: 'Steps per day',
              icon: Icons.directions_walk_rounded,
              gradient: AppColors.warmGradient,
              controller: _stepsController,
              unit: 'steps',
              isInt: true,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              title: 'Calorie Intake',
              subtitle: 'Calories per day',
              icon: Icons.local_fire_department_rounded,
              gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4B8B)]),
              controller: _caloriesController,
              unit: 'kcal',
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              title: 'Daily Hydration',
              subtitle: 'Water intake per day',
              icon: Icons.water_drop_rounded,
              gradient: AppColors.accentGradient,
              controller: _waterController,
              unit: 'ml',
              isInt: true,
            ),
            const SizedBox(height: 24),
            if (!_editMode) _buildGoalSummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationBanner() {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (_, child) => FadeTransition(opacity: _entryController, child: child),
      child: GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Goals', style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Define your\nfitness journey', style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Set. Track. Achieve.', style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: AppColors.primaryGradient,
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20, offset: const Offset(0, 10),
                )],
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 44),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required TextEditingController controller,
    required String unit,
    bool isInt = false,
    double? current,
    double? goal,
    String? currentLabel,
    String? goalLabel,
  }) {
    double progress = 0;
    if (current != null && goal != null && current != goal) {
      progress = (current / goal).clamp(0.0, 2.0);
      if (goal < current) progress = (goal / current).clamp(0.0, 1.0);
      else progress = progress.clamp(0.0, 1.0);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 10, offset: const Offset(0, 4),
                  )],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(subtitle, style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!_editMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.text.isEmpty ? 'Not set' : '${controller.text} $unit',
                    style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
            ],
          ),
          if (_editMode) ...[
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: isInt
                  ? TextInputType.number
                  : const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target $unit',
                suffixText: unit,
              ),
            ),
          ] else if (current != null && goal != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$currentLabel: ${current.toStringAsFixed(1)} $unit',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                Text('$goalLabel: ${goal.toStringAsFixed(1)} $unit',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: progress,
              backgroundColor: gradient.colors.first.withOpacity(0.1),
              linearGradient: LinearGradient(colors: gradient.colors),
              barRadius: const Radius.circular(10),
              padding: EdgeInsets.zero,
              animation: true,
              animationDuration: 1000,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalSummary() {
    final goals = [
      if (_profile.goalWeight != null)
        {'label': 'Weight Goal', 'value': '${_profile.goalWeight!.toStringAsFixed(1)} kg', 'icon': Icons.monitor_weight_rounded, 'color': AppColors.primary},
      if (_profile.targetSteps != null)
        {'label': 'Daily Steps', 'value': '${_profile.targetSteps} steps', 'icon': Icons.directions_walk_rounded, 'color': AppColors.accentOrange},
      if (_profile.targetCalories != null)
        {'label': 'Calories', 'value': '${_profile.targetCalories!.toInt()} kcal', 'icon': Icons.local_fire_department_rounded, 'color': AppColors.accentPink},
      if (_profile.targetWaterMl != null)
        {'label': 'Water', 'value': '${(_profile.targetWaterMl! / 1000).toStringAsFixed(1)} L', 'icon': Icons.water_drop_rounded, 'color': AppColors.accent},
    ];

    if (goals.isEmpty) return const SizedBox();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Goals Summary', style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: goals.map((g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (g['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(g['icon'] as IconData, color: g['color'] as Color, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g['value'] as String, style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w700, color: g['color'] as Color)),
                      Text(g['label'] as String, style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
