import 'package:flutter/material.dart';

import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..forward();
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.creamSoft, AppTheme.cream],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.50),
                      Colors.transparent,
                      AppTheme.olive.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/RUMA LOGO 1.png',
                          width: 170,
                          color: AppTheme.accent,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              'RUMA',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    color: AppTheme.accent,
                                    fontSize: 46,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3,
                                  ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Kelola kos dengan lebih nyaman',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 26),
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (context, child) {
                            return SizedBox(
                              width: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: _progress.value,
                                  minHeight: 4,
                                  backgroundColor: AppTheme.olive.withValues(
                                    alpha: 0.12,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.olive.withValues(alpha: 0.72),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
