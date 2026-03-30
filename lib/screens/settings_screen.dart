import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _weightReminder = true;
  bool _hydrationReminder = true;
  bool _workoutReminder = false;
  bool _darkMode = false;
  bool _metricUnits = true;
  String _reminderFrequency = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Settings', style: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAppSection(),
            const SizedBox(height: 20),
            _buildNotificationsSection(),
            const SizedBox(height: 20),
            _buildUnitsSection(),
            const SizedBox(height: 20),
            _buildDataSection(),
            const SizedBox(height: 20),
            _buildAboutSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
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
      ),
    );
  }

  Widget _buildSwitch(String title, String? subtitle, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle, style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance', Icons.palette_rounded, AppColors.primaryGradient),
          _buildSwitch('Dark Mode', 'Switch to dark theme', _darkMode,
            (v) => setState(() => _darkMode = v), AppColors.primary),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildDropdownRow('Reminder Frequency', _reminderFrequency, ['Daily', 'Weekly', 'Off'],
            (v) => setState(() => _reminderFrequency = v!)),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Notifications', Icons.notifications_rounded, AppColors.warmGradient),
          _buildSwitch('Push Notifications', 'Receive app notifications', _notifications,
            (v) => setState(() => _notifications = v), AppColors.accentOrange),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildSwitch('Weight Reminder', 'Daily weight log reminder', _weightReminder,
            (v) => setState(() => _weightReminder = v), AppColors.primary),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildSwitch('Hydration Reminder', 'Hourly water intake reminder', _hydrationReminder,
            (v) => setState(() => _hydrationReminder = v), AppColors.accent),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildSwitch('Workout Reminder', 'Daily exercise reminder', _workoutReminder,
            (v) => setState(() => _workoutReminder = v), AppColors.accentPink),
        ],
      ),
    );
  }

  Widget _buildUnitsSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Units & Measurement', Icons.straighten_rounded, AppColors.accentGradient),
          _buildSwitch('Metric System', 'Use kg, cm, ml', _metricUnits,
            (v) => setState(() => _metricUnits = v), AppColors.accent),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _metricUnits
                        ? 'Using: kg, cm, ml, kcal'
                        : 'Using: lbs, ft/in, fl oz, kcal',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Data & Privacy', Icons.security_rounded,
            const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
          _buildActionRow('Export Data', 'Download your health data', Icons.download_rounded, AppColors.primary),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildActionRow('Backup & Sync', 'Sync to cloud storage', Icons.cloud_upload_rounded, AppColors.accent),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildActionRow('Clear All Data', 'Delete all records', Icons.delete_rounded, AppColors.error, danger: true),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About', Icons.info_rounded, AppColors.warmGradient),
          _buildActionRow('Privacy Policy', 'Read our privacy policy', Icons.privacy_tip_rounded, AppColors.textSecondary),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildActionRow('Terms of Service', 'View terms and conditions', Icons.description_rounded, AppColors.textSecondary),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          _buildActionRow('Rate the App', 'Leave a review', Icons.star_rounded, AppColors.warning),
          const Divider(color: AppColors.surfaceSecondary, height: 24),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Column(
                children: [
                  Text('FitTrack', style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text('Version 1.0.0', style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
                  Text('Your Athletic Health Partner', style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String title, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: options.map((o) => DropdownMenuItem(
                value: o,
                child: Text(o, style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              )).toList(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(String title, String subtitle, IconData icon, Color color, {bool danger = false}) {
    return GestureDetector(
      onTap: danger ? _showDeleteConfirmation : () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: danger ? AppColors.error : AppColors.textPrimary)),
                Text(subtitle, style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Clear All Data?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('This will permanently delete all your health records. This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
