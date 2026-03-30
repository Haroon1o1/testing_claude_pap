import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/health_data.dart';
import '../utils/data_manager.dart';
import 'home_screen.dart';
import 'record_screen.dart';
import 'graphs_screen.dart';
import 'reports_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _drawerController;
  late AnimationController _navController;
  late Animation<double> _drawerAnimation;
  late Animation<double> _navAnimation;
  UserProfile _profile = UserProfile.defaultProfile();

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: 'Record'),
    _NavItem(icon: Icons.bar_chart_rounded, activeIcon: Icons.bar_chart_rounded, label: 'Graphs'),
    _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description_rounded, label: 'Reports'),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    RecordScreen(),
    GraphsScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _navController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _drawerAnimation = CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic);
    _navAnimation = CurvedAnimation(parent: _navController, curve: Curves.elasticOut);
    _navController.forward();
    _loadProfile();
  }

  void _loadProfile() async {
    final profile = await DataManager.getProfile();
    setState(() => _profile = profile);
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _navController.dispose();
    super.dispose();
  }

  void _openDrawer() => _drawerController.forward();
  void _closeDrawer() => _drawerController.reverse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          _screens[_currentIndex],
          // Bottom Nav
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),
          // Drawer overlay
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (_, __) {
              if (_drawerAnimation.value == 0) return const SizedBox();
              return GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                  color: Colors.black.withOpacity(0.4 * _drawerAnimation.value),
                ),
              );
            },
          ),
          // Side Drawer
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder: (_, child) {
              final offset = (-1 + _drawerAnimation.value) * 280;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: _buildDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(_navAnimation),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 0,
              offset: Offset(0, -1),
            ),
          ],
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          children: [
            // Hamburger menu button
            GestureDetector(
              onTap: _openDrawer,
              child: Container(
                width: 46, height: 46,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 22),
              ),
            ),
            // Nav items
            ..._navItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isActive = _currentIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryGradient : null,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isActive ? [BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12, offset: const Offset(0, 4),
                      )] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isActive ? item.activeIcon : item.icon,
                          color: isActive ? Colors.white : AppColors.textLight,
                          size: 22),
                        if (isActive) ...[
                          const SizedBox(height: 2),
                          Text(item.label, style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final drawerItems = [
      _DrawerItem(icon: Icons.home_rounded, label: 'Home', index: 0),
      _DrawerItem(icon: Icons.add_circle_rounded, label: 'Record', index: 1),
      _DrawerItem(icon: Icons.bar_chart_rounded, label: 'Analytics', index: 2),
      _DrawerItem(icon: Icons.description_rounded, label: 'Reports', index: 3),
    ];

    final extraItems = [
      _DrawerExtraItem(icon: Icons.flag_rounded, label: 'Set Goals', screen: const GoalsScreen()),
      _DrawerExtraItem(icon: Icons.person_rounded, label: 'Profile', screen: const ProfileScreen()),
      _DrawerExtraItem(icon: Icons.settings_rounded, label: 'Settings', screen: const SettingsScreen()),
    ];

    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 30,
          offset: const Offset(10, 0),
        )],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'A',
                            style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _closeDrawer,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_profile.name, style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('BMI: ${_profile.bmi.toStringAsFixed(1)} • ${_profile.bmiCategory}',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            // Nav items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text('MAIN', style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.textLight, letterSpacing: 1.5)),
                    ),
                    ...drawerItems.map((item) => _buildDrawerNavItem(item)),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text('MORE', style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.textLight, letterSpacing: 1.5)),
                    ),
                    ...extraItems.map((item) => _buildDrawerExtraItem(item)),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FitTrack', style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      Text('v1.0.0', style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem(_DrawerItem item) {
    final isActive = _currentIndex == item.index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = item.index);
        _closeDrawer();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8, offset: const Offset(0, 4),
          )] : null,
        ),
        child: Row(
          children: [
            Icon(item.icon, color: isActive ? Colors.white : AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(item.label, style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textPrimary,
            )),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerExtraItem(_DrawerExtraItem item) {
    return GestureDetector(
      onTap: () {
        _closeDrawer();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            Navigator.push(context, PageRouteBuilder(
              pageBuilder: (_, __, ___) => item.screen,
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ));
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(item.label, style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final int index;
  _DrawerItem({required this.icon, required this.label, required this.index});
}

class _DrawerExtraItem {
  final IconData icon;
  final String label;
  final Widget screen;
  _DrawerExtraItem({required this.icon, required this.label, required this.screen});
}
