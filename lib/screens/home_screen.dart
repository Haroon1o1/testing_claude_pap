import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  UserProfile _profile = UserProfile.defaultProfile();
  DailyActivity? _todayActivity;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadData();
  }

  void _loadData() async {
    final profile = await DataManager.getProfile();
    final activities = await DataManager.getActivities();
    final today = DateTime.now();
    DailyActivity? todayAct = activities.where((a) =>
      a.date.year == today.year &&
      a.date.month == today.month &&
      a.date.day == today.day
    ).firstOrNull;
    todayAct ??= DailyActivity(date: today, steps: 7342, caloriesBurned: 380, waterMl: 1800, sleepMinutes: 450, workoutMinutes: 35);

    setState(() {
      _profile = profile;
      _todayActivity = todayAct;
    });
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreetingCard(),
                const SizedBox(height: 24),
                _buildBMICard(),
                const SizedBox(height: 24),
                _buildTodayStats(),
                const SizedBox(height: 24),
                _buildActivityRings(),
                const SizedBox(height: 24),
                _buildWeeklyOverview(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'FitTrack',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ).createShader(const Rect.fromLTWH(0, 0, 150, 40)),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final emoji = hour < 12 ? '🌅' : hour < 17 ? '⚡' : '🌙';

    return _AnimatedEntry(
      controller: _entryController,
      delay: 0.0,
      child: GradientCard(
        gradient: AppColors.primaryGradient,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting $emoji',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Keep pushing! You\'re doing great',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 5, left: 5,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 38),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    final bmi = _profile.bmi;
    final category = _profile.bmiCategory;
    Color bmiColor = AppColors.success;
    if (category == 'Underweight') bmiColor = AppColors.warning;
    if (category == 'Overweight') bmiColor = AppColors.accentOrange;
    if (category == 'Obese') bmiColor = AppColors.error;

    return _AnimatedEntry(
      controller: _entryController,
      delay: 0.1,
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BMI Index', style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(bmi.toStringAsFixed(1), style: GoogleFonts.poppins(
                    color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w800)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bmiColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(category, style: GoogleFonts.poppins(
                      color: bmiColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMiniStat('Weight', '${_profile.currentWeight?.toStringAsFixed(1) ?? "--"} kg', AppColors.primary),
                const SizedBox(height: 12),
                _buildMiniStat('Height', '${_profile.currentHeight?.toStringAsFixed(0) ?? "--"} cm', AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value, style: GoogleFonts.poppins(
            color: color, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(label, style: GoogleFonts.poppins(
            color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    final act = _todayActivity;
    if (act == null) return const SizedBox();

    return _AnimatedEntry(
      controller: _entryController,
      delay: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Stats", style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Steps', act.steps.toString(), Icons.directions_walk_rounded, AppColors.primaryGradient, '/ ${_profile.targetSteps ?? 10000}')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Calories', '${act.caloriesBurned.toInt()}', Icons.local_fire_department_rounded, AppColors.warmGradient, 'kcal')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Water', '${(act.waterMl / 1000).toStringAsFixed(1)}L', Icons.water_drop_rounded, AppColors.accentGradient, '/ ${(((_profile.targetWaterMl ?? 2500)) / 1000).toStringAsFixed(1)}L')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Sleep', '${(act.sleepMinutes / 60).toStringAsFixed(1)}h', Icons.bedtime_rounded, const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]), 'hours')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Gradient gradient, String unit) {
    return GradientCard(
      gradient: gradient,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(unit, style: GoogleFonts.poppins(
            color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActivityRings() {
    final act = _todayActivity;
    if (act == null) return const SizedBox();
    final stepsGoal = _profile.targetSteps ?? 10000;
    final waterGoal = _profile.targetWaterMl ?? 2500;
    final calGoal = _profile.targetCalories ?? 2000;

    return _AnimatedEntry(
      controller: _entryController,
      delay: 0.3,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Rings', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRing('Steps', act.steps / stepsGoal, AppColors.primary),
                _buildRing('Water', act.waterMl / waterGoal, AppColors.accent),
                _buildRing('Calories', act.caloriesBurned / calGoal, AppColors.accentOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(String label, double percent, Color color) {
    final clamped = percent.clamp(0.0, 1.0);
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 45,
          lineWidth: 10,
          percent: clamped,
          center: Text('${(clamped * 100).toInt()}%', style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          progressColor: color,
          backgroundColor: color.withOpacity(0.1),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1200,
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildWeeklyOverview() {
    return _AnimatedEntry(
      controller: _entryController,
      delay: 0.4,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Week', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = DateTime.now().subtract(Duration(days: 6 - i));
                final isToday = i == 6;
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final dayName = days[day.weekday - 1];
                final height = (0.3 + (i * 0.1) % 0.7);

                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isToday ? null : AppColors.surfaceSecondary,
                        gradient: isToday ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isToday ? [BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )] : null,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: isToday ? 1.0 : height,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday ? null : AppColors.primary.withOpacity(0.3),
                            gradient: isToday ? null : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(dayName, style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday ? AppColors.primary : AppColors.textSecondary)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedEntry({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final begin = delay;
    final end = (delay + 0.4).clamp(0.0, 1.0);

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
    final slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(position: slideAnim, child: child),
      ),
    );
  }
}
