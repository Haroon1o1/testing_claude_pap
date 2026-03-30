import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _bgScale;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseAnim;
  late Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _bgScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOutQuart),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_particleController);

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _textController,
          _pulseController,
          _particleController,
        ]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8F9FF),
                  Color(0xFFEEEDFF),
                  Color(0xFFE8F4FD),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Animated background circles
                ..._buildBackgroundCircles(),
                // Floating particles
                ..._buildParticles(),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Logo
                      ScaleTransition(
                        scale: _logoScale,
                        child: RotationTransition(
                          turns: _logoRotate,
                          child: ScaleTransition(
                            scale: _pulseAnim,
                            child: _buildLogo(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // App name
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(
                                'FitTrack',
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.accent,
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70),
                                    ),
                                ),
                              ),
                              Text(
                                'Your Athletic Health Partner',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                      FadeTransition(
                        opacity: _textFade,
                        child: _buildLoadingDots(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 3D shine effect
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monitor_heart_rounded,
                    color: Colors.white, size: 52),
                const SizedBox(height: 4),
                Text(
                  'FIT',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -100 + (_bgScale.value * 50),
        left: -80,
        child: Opacity(
          opacity: _bgScale.value * 0.12,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -120 + (_bgScale.value * 60),
        right: -100,
        child: Opacity(
          opacity: _bgScale.value * 0.1,
          child: Container(
            width: 350,
            height: 350,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
      Positioned(
        top: 200,
        right: -50,
        child: Opacity(
          opacity: _bgScale.value * 0.08,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPink,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildParticles() {
    final screenSize = MediaQuery.of(context).size;
    final particles = [
      {'x': 0.1, 'y': 0.2, 'size': 8.0, 'color': AppColors.primary},
      {'x': 0.85, 'y': 0.15, 'size': 6.0, 'color': AppColors.accent},
      {'x': 0.25, 'y': 0.75, 'size': 10.0, 'color': AppColors.accentOrange},
      {'x': 0.7, 'y': 0.65, 'size': 7.0, 'color': AppColors.primaryLight},
      {'x': 0.5, 'y': 0.1, 'size': 5.0, 'color': AppColors.accentPink},
      {'x': 0.15, 'y': 0.5, 'size': 9.0, 'color': AppColors.accent},
      {'x': 0.9, 'y': 0.45, 'size': 6.0, 'color': AppColors.primary},
    ];

    return particles.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      final phase = (i * 0.4) % 1.0;
      final animValue = (_particleAnim.value + phase) % 1.0;
      final floatOffset = (animValue < 0.5 ? animValue : 1.0 - animValue) * 20;

      return Positioned(
        left: (p['x'] as double) * screenSize.width,
        top: (p['y'] as double) * screenSize.height + floatOffset - 10,
        child: Opacity(
          opacity: 0.4 * _bgScale.value,
          child: Container(
            width: p['size'] as double,
            height: p['size'] as double,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p['color'] as Color,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final delay = i * 0.3;
        final val = (_pulseController.value - delay).clamp(0.0, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.3 + val * 0.7),
          ),
        );
      }),
    );
  }
}
