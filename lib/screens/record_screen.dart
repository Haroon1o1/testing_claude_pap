import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import '../widgets/glass_card.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _noteController = TextEditingController();
  List<WeightEntry> _weightEntries = [];
  List<HeightEntry> _heightEntries = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    final w = await DataManager.getWeightEntries();
    final h = await DataManager.getHeightEntries();
    setState(() {
      _weightEntries = w.reversed.toList();
      _heightEntries = h.reversed.toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveWeight() async {
    final val = double.tryParse(_weightController.text);
    if (val == null || val <= 0) {
      _showError('Please enter a valid weight');
      return;
    }
    setState(() => _loading = true);
    await DataManager.saveWeightEntry(
      WeightEntry(date: DateTime.now(), weight: val, note: _noteController.text.isEmpty ? null : _noteController.text),
    );
    _weightController.clear();
    _noteController.clear();
    _loadData();
    setState(() => _loading = false);
    if (mounted) _showSuccess('Weight recorded!');
  }

  Future<void> _saveHeight() async {
    final val = double.tryParse(_heightController.text);
    if (val == null || val <= 0) {
      _showError('Please enter a valid height');
      return;
    }
    setState(() => _loading = true);
    await DataManager.saveHeightEntry(HeightEntry(date: DateTime.now(), height: val));
    _heightController.clear();
    _loadData();
    setState(() => _loading = false);
    if (mounted) _showSuccess('Height recorded!');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Record', style: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Weight'),
            Tab(text: 'Height'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeightTab(),
          _buildHeightTab(),
        ],
      ),
    );
  }

  Widget _buildWeightTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRecordCard(
            title: 'Log Weight',
            icon: Icons.monitor_weight_rounded,
            gradient: AppColors.primaryGradient,
            child: Column(
              children: [
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_rounded, color: AppColors.primary),
                    suffixText: 'kg',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveWeight,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Save Weight', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHistorySection('Weight History', _weightEntries.map((e) =>
            _HistoryItem(
              date: e.date,
              value: '${e.weight.toStringAsFixed(1)} kg',
              note: e.note,
              color: AppColors.primary,
              icon: Icons.monitor_weight_rounded,
            )
          ).toList()),
        ],
      ),
    );
  }

  Widget _buildHeightTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRecordCard(
            title: 'Log Height',
            icon: Icons.height_rounded,
            gradient: AppColors.accentGradient,
            child: Column(
              children: [
                TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Icons.height_rounded, color: AppColors.accent),
                    suffixText: 'cm',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveHeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shadowColor: AppColors.accent.withOpacity(0.4),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Save Height', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildHistorySection('Height History', _heightEntries.map((e) =>
            _HistoryItem(
              date: e.date,
              value: '${e.height.toStringAsFixed(1)} cm',
              color: AppColors.accent,
              icon: Icons.height_rounded,
            )
          ).toList()),
        ],
      ),
    );
  }

  Widget _buildRecordCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Widget child,
  }) {
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
                    blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildHistorySection(String title, List<_HistoryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        if (items.isEmpty)
          GlassCard(
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.history, size: 48, color: AppColors.textLight),
                  const SizedBox(height: 8),
                  Text('No records yet', style: GoogleFonts.poppins(
                    color: AppColors.textLight, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          ...items.take(10).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.value, style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        if (item.note != null)
                          Text(item.note!, style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(DateFormat('MMM d').format(item.date), style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )),
      ],
    );
  }
}

class _HistoryItem {
  final DateTime date;
  final String value;
  final String? note;
  final Color color;
  final IconData icon;

  _HistoryItem({
    required this.date,
    required this.value,
    this.note,
    required this.color,
    required this.icon,
  });
}
