import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

/// WelcomeScreen — Tampil pertama untuk tenant yang belum login.
/// Dua pilihan: Lanjutkan (lihat fitur) atau Masuk ke Akun (langsung login).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goToOnboarding() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const OnboardingScreen(),
        transitionsBuilder: (ctx2, anim, sec2, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const LoginScreen(),
        transitionsBuilder: (ctx2, anim, sec2, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ── Header: RUMA brand ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.lightBeige.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Image.asset(
                            'assets/RUMA LOGO 1.png',
                            color: AppTheme.lightBeige,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'RUMA',
                        style: GoogleFonts.poppins(
                          color: AppTheme.lightBeige,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Illustration Area ──
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Ambient radial glow
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.lightBeige.withValues(alpha: 0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Central illustration card
                          Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: AppTheme.border.withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  offset: const Offset(0, 16),
                                  blurRadius: 48,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/RUMA LOGO 1.png',
                                  height: 80,
                                  color: AppTheme.olive,
                                  errorBuilder: (ctx, e, t) => const Icon(
                                    Icons.apartment_rounded,
                                    size: 80,
                                    color: AppTheme.olive,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'TENANT',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF47483c),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3,
                                  ),
                                ),
                                Text(
                                  'Smart Tenant Assistant',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF77786b),
                                    fontSize: 8,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Floating badge: Credit Card (Top Right)
                          Positioned(
                            top: 10,
                            right: -4,
                            child: _badge(
                              icon: Icons.credit_card_rounded,
                              color: AppTheme.olive,
                            ),
                          ),

                          // Floating badge: Report (Bottom Left)
                          Positioned(
                            bottom: 16,
                            left: -12,
                            child: _badge(
                              icon: Icons.assignment_late_rounded,
                              color: AppTheme.olive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Copy ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        'Kos Lebih Nyaman\n& Praktis',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppTheme.lightBeige,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bayar tagihan sewa instan, laporkan fasilitas rusak,\ndan pantau status kost Anda dalam satu genggaman.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppTheme.lightBeige.withValues(alpha: 0.8),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Action Buttons ──
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Primary: Lanjutkan → lihat fitur
                      ElevatedButton(
                        onPressed: _goToOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBeige,
                          foregroundColor: AppTheme.oliveDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lanjutkan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.oliveDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.oliveDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Secondary: Langsung masuk
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'MASUK KE AKUN',
                          style: GoogleFonts.poppins(
                            color: AppTheme.lightBeige,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Footer ──
                const SizedBox(height: 8),
                Text(
                  'PROFESSIONAL PROPERTY MANAGEMENT',
                  style: GoogleFonts.poppins(
                    color: AppTheme.lightBeige.withValues(alpha: 0.4),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
