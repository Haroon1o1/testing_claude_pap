import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import '../widgets/glass_card.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WeightEntry> _weightEntries = [];
  List<DailyActivity> _activities = [];
  int _selectedPeriod = 0; // 0=1W, 1=1M, 2=3M

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() async {
    final w = await DataManager.getWeightEntries();
    final a = await DataManager.getActivities();
    setState(() {
      _weightEntries = w;
      _activities = a;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Analytics', style: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Weight'),
            Tab(text: 'Activity'),
            Tab(text: 'Wellness'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeightTab(),
          _buildActivityTab(),
          _buildWellnessTab(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final labels = ['1 Week', '1 Month', '3 Months'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) => GestureDetector(
        onTap: () => setState(() => _selectedPeriod = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: _selectedPeriod == i ? AppColors.primaryGradient : null,
            color: _selectedPeriod == i ? null : AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _selectedPeriod == i ? [BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )] : null,
          ),
          child: Text(labels[i], style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _selectedPeriod == i ? Colors.white : AppColors.textSecondary,
          )),
        ),
      )),
    );
  }

  List<WeightEntry> get _filteredWeightEntries {
    final now = DateTime.now();
    final days = [7, 30, 90][_selectedPeriod];
    final cutoff = now.subtract(Duration(days: days));
    return _weightEntries.where((e) => e.date.isAfter(cutoff)).toList();
  }

  List<DailyActivity> get _filteredActivities {
    final now = DateTime.now();
    final days = [7, 30, 90][_selectedPeriod];
    final cutoff = now.subtract(Duration(days: days));
    return _activities.where((e) => e.date.isAfter(cutoff)).toList();
  }

  Widget _buildWeightTab() {
    final entries = _filteredWeightEntries;
    if (entries.isEmpty) return _buildEmptyState('No weight data');

    final spots = entries.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value.weight)
    ).toList();

    final minW = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxW = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartHeader('Weight Trend', 'kg', AppColors.primaryGradient),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.textLight.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) => Text(
                            v.toStringAsFixed(0),
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= entries.length) return const SizedBox();
                            if (entries.length > 8 && idx % 3 != 0) return const SizedBox();
                            return Text(
                              DateFormat('d/M').format(entries[idx].date),
                              style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: minW,
                    maxY: maxW,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        gradient: AppColors.primaryGradient,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.primary,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWeightStats(entries),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWeightStats(List<WeightEntry> entries) {
    if (entries.isEmpty) return const SizedBox();
    final latest = entries.last.weight;
    final oldest = entries.first.weight;
    final diff = latest - oldest;
    final avg = entries.map((e) => e.weight).reduce((a, b) => a + b) / entries.length;

    return Row(
      children: [
        Expanded(child: _buildStatChip('Current', '${latest.toStringAsFixed(1)} kg', AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Average', '${avg.toStringAsFixed(1)} kg', AppColors.accent)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatChip('Change', '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
          diff < 0 ? AppColors.success : AppColors.accentOrange)),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    final acts = _filteredActivities;
    if (acts.isEmpty) return _buildEmptyState('No activity data');

    final barGroups = acts.asMap().entries.map((entry) {
      final i = entry.key;
      final a = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: a.steps.toDouble(),
          gradient: AppColors.primaryGradient,
          width: acts.length > 14 ? 6 : 14,
          borderRadius: BorderRadius.circular(6),
        )],
      );
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartHeader('Daily Steps', 'steps', AppColors.primaryGradient),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(BarChartData(
                    barGroups: barGroups,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.textLight.withOpacity(0.3),
                        strokeWidth: 1, dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= acts.length) return const SizedBox();
                            if (acts.length > 10 && idx % 3 != 0) return const SizedBox();
                            return Text(DateFormat('d/M').format(acts[idx].date),
                              style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, reservedSize: 46,
                          getTitlesWidget: (v, _) => Text(
                            '${(v / 1000).toStringAsFixed(0)}k',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: true),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartHeader('Calories Burned', 'kcal', AppColors.warmGradient),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.textLight.withOpacity(0.3),
                        strokeWidth: 1, dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                      )),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: acts.asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), e.value.caloriesBurned)).toList(),
                      isCurved: true,
                      gradient: AppColors.warmGradient,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [AppColors.accentOrange.withOpacity(0.3), Colors.transparent],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    )],
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWellnessTab() {
    final acts = _filteredActivities;
    if (acts.isEmpty) return _buildEmptyState('No wellness data');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartHeader('Sleep Duration', 'hours', const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: BarChart(BarChartData(
                    barGroups: acts.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [BarChartRodData(
                          toY: entry.value.sleepMinutes / 60,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                          width: acts.length > 14 ? 6 : 14,
                          borderRadius: BorderRadius.circular(6),
                        )],
                      );
                    }).toList(),
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.textLight.withOpacity(0.3),
                        strokeWidth: 1, dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 36,
                        getTitlesWidget: (v, _) => Text('${v.toStringAsFixed(0)}h',
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                      )),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartHeader('Hydration', 'ml', AppColors.accentGradient),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.textLight.withOpacity(0.3),
                        strokeWidth: 1, dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 40,
                        getTitlesWidget: (v, _) => Text('${(v / 1000).toStringAsFixed(1)}L',
                          style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary)),
                      )),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: acts.asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), e.value.waterMl.toDouble())).toList(),
                      isCurved: true,
                      gradient: AppColors.accentGradient,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [AppColors.accent.withOpacity(0.3), Colors.transparent],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    )],
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildChartHeader(String title, String unit, Gradient gradient) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(unit, style: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(msg, style: GoogleFonts.poppins(
            color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
