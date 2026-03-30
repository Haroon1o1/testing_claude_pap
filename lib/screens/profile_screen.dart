import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  UserProfile _profile = UserProfile.defaultProfile();
  bool _editMode = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'Male';

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
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _weightController.text = profile.currentWeight?.toStringAsFixed(1) ?? '';
      _heightController.text = profile.currentHeight?.toStringAsFixed(0) ?? '';
      _selectedGender = profile.gender;
    });
    _entryController.forward();
  }

  Future<void> _saveProfile() async {
    _profile.name = _nameController.text.isEmpty ? 'Athlete' : _nameController.text;
    _profile.age = int.tryParse(_ageController.text) ?? 25;
    _profile.currentWeight = double.tryParse(_weightController.text);
    _profile.currentHeight = double.tryParse(_heightController.text);
    _profile.gender = _selectedGender;
    await DataManager.saveProfile(_profile);
    setState(() => _editMode = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_editMode) _saveProfile();
              else setState(() => _editMode = true);
            },
            icon: Icon(_editMode ? Icons.check_rounded : Icons.edit_rounded, color: AppColors.primary),
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
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildPersonalInfo(),
            const SizedBox(height: 20),
            _buildBodyInfo(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildAchievements(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (_, child) => FadeTransition(opacity: _entryController, child: child),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          width: 35, height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'A',
                          style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4, right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 8, offset: const Offset(0, 4),
                      )],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_profile.name, style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('${_profile.age} years • ${_profile.gender}', style: GoogleFonts.poppins(
              fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10, offset: const Offset(0, 4),
                )],
              ),
              child: Text('BMI: ${_profile.bmi.toStringAsFixed(1)} • ${_profile.bmiCategory}',
                style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information', Icons.person_rounded, AppColors.primaryGradient),
          const SizedBox(height: 20),
          if (_editMode) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            _buildGenderSelector(),
          ] else ...[
            _buildInfoRow('Name', _profile.name, Icons.person_outline_rounded),
            const Divider(height: 20, color: AppColors.surfaceSecondary),
            _buildInfoRow('Age', '${_profile.age} years', Icons.cake_rounded),
            const Divider(height: 20, color: AppColors.surfaceSecondary),
            _buildInfoRow('Gender', _profile.gender, Icons.wc_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildBodyInfo() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Body Measurements', Icons.straighten_rounded, AppColors.accentGradient),
          const SizedBox(height: 20),
          if (_editMode) ...[
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight_rounded, color: AppColors.accent),
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height_rounded, color: AppColors.accent),
                suffixText: 'cm',
              ),
            ),
          ] else ...[
            _buildInfoRow('Weight', '${_profile.currentWeight?.toStringAsFixed(1) ?? "--"} kg', Icons.monitor_weight_rounded),
            const Divider(height: 20, color: AppColors.surfaceSecondary),
            _buildInfoRow('Height', '${_profile.currentHeight?.toStringAsFixed(0) ?? "--"} cm', Icons.height_rounded),
            const Divider(height: 20, color: AppColors.surfaceSecondary),
            _buildInfoRow('BMI', _profile.bmi.toStringAsFixed(1), Icons.analytics_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: GoogleFonts.poppins(
          fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedGender = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: _selectedGender == g ? AppColors.primaryGradient : null,
                  color: _selectedGender == g ? null : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _selectedGender == g ? [BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 4),
                  )] : null,
                ),
                child: Text(g, textAlign: TextAlign.center, style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _selectedGender == g ? Colors.white : AppColors.textSecondary,
                )),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatChip('Goal Weight',
          '${_profile.goalWeight?.toStringAsFixed(1) ?? "--"} kg',
          Icons.flag_rounded, AppColors.accentOrange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Daily Steps',
          '${_profile.targetSteps ?? "--"}',
          Icons.directions_walk_rounded, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Calories',
          '${_profile.targetCalories?.toInt() ?? "--"}',
          Icons.local_fire_department_rounded, AppColors.accentPink)),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final badges = [
      {'icon': Icons.emoji_events_rounded, 'label': 'First Step', 'color': AppColors.warning, 'unlocked': true},
      {'icon': Icons.local_fire_department_rounded, 'label': '7 Day Streak', 'color': AppColors.accentOrange, 'unlocked': true},
      {'icon': Icons.water_drop_rounded, 'label': 'Hydrated', 'color': AppColors.accent, 'unlocked': false},
      {'icon': Icons.fitness_center_rounded, 'label': 'Workout', 'color': AppColors.primary, 'unlocked': false},
      {'icon': Icons.bedtime_rounded, 'label': 'Sleep Pro', 'color': Color(0xFF764BA2), 'unlocked': false},
      {'icon': Icons.star_rounded, 'label': 'Goal Reached', 'color': AppColors.success, 'unlocked': false},
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Achievements', Icons.emoji_events_rounded, AppColors.warmGradient),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: badges.map((b) {
              final unlocked = b['unlocked'] as bool;
              final color = b['color'] as Color;
              return Column(
                children: [
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      gradient: unlocked ? LinearGradient(colors: [color, color.withOpacity(0.7)]) : null,
                      color: unlocked ? null : AppColors.surfaceSecondary,
                      shape: BoxShape.circle,
                      boxShadow: unlocked ? [BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12, offset: const Offset(0, 6),
                      )] : null,
                    ),
                    child: Icon(b['icon'] as IconData,
                      color: unlocked ? Colors.white : AppColors.textLight,
                      size: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(b['label'] as String, style: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: unlocked ? AppColors.textPrimary : AppColors.textLight),
                    textAlign: TextAlign.center),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: GoogleFonts.poppins(
            fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Text(value, style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}
