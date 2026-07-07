import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// AuthScreen — "Home Splash 2", tampil setelah semua feature slides.
/// Design: dark-olive gradient premium konsisten dengan desain login.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _btnCtrl;
  late AnimationController _floatCtrl;

  // Animations
  late Animation<double> _bgFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _btnSlide;
  late Animation<double> _btnFade;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
    _glowOpacity = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);

    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOutCubic));
    _btnFade = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut);

    _floatAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Staggered sequence
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _btnCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _btnCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const LoginScreen(),
        transitionsBuilder: (ctx2, anim, sec2, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  void _goToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const RegisterScreen(),
        transitionsBuilder: (ctx2, anim, sec2, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.oliveDark,
                AppTheme.olive,
              ],
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative background circles ──
              _buildBgCircle(top: -100, right: -60, size: 280, opacity: 0.06),
              _buildBgCircle(bottom: -120, left: -80, size: 320, opacity: 0.05),
              _buildBgCircle(top: 200, left: -40, size: 160, opacity: 0.04),

              // ── Floating particles ──
              AnimatedBuilder(
                animation: _floatAnim,
                builder: (context, child) {
                  final offset = (_floatAnim.value - 0.5) * 16;
                  return Stack(
                    children: [
                      _floatingDot(top: 140 + offset, left: 40, size: 5, opacity: 0.25),
                      _floatingDot(top: 200 - offset * 0.6, right: 50, size: 4, opacity: 0.18),
                      _floatingDot(bottom: 280 + offset * 0.8, left: 80, size: 6, opacity: 0.2),
                      _floatingDot(bottom: 200 - offset, right: 40, size: 4, opacity: 0.22),
                      _floatingDot(top: 360 + offset * 0.5, right: 80, size: 3, opacity: 0.15),
                    ],
                  );
                },
              ),

              // ── Main Content ──
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button
                      if (Navigator.canPop(context))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: FadeTransition(
                              opacity: _bgFade,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const Spacer(flex: 2),

                      // ── LOGO SECTION ──
                      Center(
                        child: AnimatedBuilder(
                          animation: _logoCtrl,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacity.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer glow ring
                                    Opacity(
                                      opacity: (_glowOpacity.value * 0.35).clamp(0.0, 1.0),
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.lightBeige,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Inner glow
                                    Opacity(
                                      opacity: (_glowOpacity.value * 0.2).clamp(0.0, 1.0),
                                      child: Container(
                                        width: 148,
                                        height: 148,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.lightBeige,
                                        ),
                                      ),
                                    ),
                                    // Logo card
                                    Container(
                                      width: 128,
                                      height: 128,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/RUMA LOGO 1.png',
                                          height: 72,
                                          color: AppTheme.lightBeige,
                                          errorBuilder: (ctx, e, t) => const Icon(
                                            Icons.apartment_rounded,
                                            size: 64,
                                            color: AppTheme.lightBeige,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Checkmark badge (top right of circle)
                                    Opacity(
                                      opacity: _glowOpacity.value.clamp(0.0, 1.0),
                                      child: Positioned(
                                        child: Transform.translate(
                                          offset: const Offset(52, -52),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightBeige,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.lightBeige.withValues(alpha: 0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: AppTheme.oliveDark,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── TEXT SECTION ──
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            children: [
                              Text(
                                'Siap Memulai? 🚀',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Kelola kos Anda lebih mudah, cepat,\ndan profesional bersama RUMA.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 14,
                                  height: 1.65,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Feature pills row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _featurePill(Icons.bar_chart_rounded, 'Keuangan'),
                                    const SizedBox(width: 8),
                                    _featurePill(Icons.people_alt_rounded, 'Penghuni'),
                                    const SizedBox(width: 8),
                                    _featurePill(Icons.home_work_rounded, 'Kamar'),
                                    const SizedBox(width: 8),
                                    _featurePill(Icons.notifications_rounded, 'Notifikasi'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // ── BUTTONS ──
                      SlideTransition(
                        position: _btnSlide,
                        child: FadeTransition(
                          opacity: _btnFade,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Primary: Masuk ke RUMA
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.lightBeige.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _goToLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.lightBeige,
                                    foregroundColor: AppTheme.oliveDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Masuk ke RUMA',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.oliveDark,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.login_rounded,
                                        size: 18,
                                        color: AppTheme.oliveDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Secondary: Buat Akun Baru
                              OutlinedButton(
                                onPressed: _goToRegister,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppTheme.lightBeige.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                                child: Text(
                                  'Buat Akun Baru',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.lightBeige,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Footer
                              Text(
                                'RUMA · PROFESSIONAL PROPERTY MANAGEMENT',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBgCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }

  Widget _floatingDot({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.lightBeige.withValues(alpha: opacity),
        ),
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.lightBeige, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
