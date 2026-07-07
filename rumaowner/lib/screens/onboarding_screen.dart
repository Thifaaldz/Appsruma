import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../data/owner_design_data.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  // Interactive slide states
  double _occupancyValue = 0.75;
  String _occupancyLabel = '75%';
  String _roomStatus = 'Tersedia';
  Color _roomStatusBg = AppTheme.statusGreenBg;
  Color _roomStatusText = AppTheme.statusGreenText;

  String _tenantBillingStatus = 'Belum Bayar';
  Color _tenantBillingBg = AppTheme.statusYellowBg;
  Color _tenantBillingText = AppTheme.statusYellowText;

  String _paymentStatus = 'BERHASIL';
  Color _paymentColor = AppTheme.olive;
  IconData _paymentIcon = Icons.check_circle_outline_rounded;

  String _complaintStatus = 'In Progress';
  Color _complaintStatusBg = AppTheme.statusBlueBg;
  Color _complaintStatusText = AppTheme.statusBlueText;
  String _complaintStepText = 'Tukang dalam perjalanan';
  IconData _complaintStepIcon = Icons.check_circle;

  bool _announcementSent = false;
  int _selectedMetricIndex = 0;
  int _welcomeTapCount = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToAuthScreen();
    }
  }

  void _goToAuthScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const AuthScreen(),
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
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
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
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBeige.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/RUMA LOGO 1.png',
                            color: AppTheme.lightBeige,
                            height: 22,
                            width: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RUMA',
                          style: GoogleFonts.poppins(
                            color: AppTheme.lightBeige,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _goToAuthScreen,
                      child: Text(
                        'LEWATI',
                        style: GoogleFonts.poppins(
                          color: AppTheme.lightBeige.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Content (Illustrations & Texts)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return _buildPageContent(index);
                  },
                ),
              ),

              // Footer (Progress Dots & Buttons)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 7,
                          width: isActive ? 24 : 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.lightBeige
                                : AppTheme.lightBeige.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Actions Buttons
                    Row(
                      children: [
                        // Back Button (only show if not on first page)
                        if (_currentPage > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _prevPage,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.lightBeige, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Kembali',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.lightBeige,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],

                        // Next/Get Started Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightBeige,
                              foregroundColor: AppTheme.oliveDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _totalPages - 1
                                      ? 'Selesai & Lanjut'
                                      : _currentPage == 0
                                          ? 'Mulai'
                                          : 'Lanjut',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.oliveDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: AppTheme.oliveDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // "LEWATI SEMUA" pada slide pertama
                    if (_currentPage == 0) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _goToAuthScreen,
                        child: Text(
                          'LEWATI SEMUA',
                          style: GoogleFonts.poppins(
                            color: AppTheme.lightBeige.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return _buildWelcomeSlide();
      case 1:
        return _buildOccupancySlide();
      case 2:
        return _buildRoomSlide();
      case 3:
        return _buildTenantSlide();
      case 4:
        return _buildPaymentSlide();
      case 5:
        return _buildComplaintSlide();
      case 6:
        return _buildAnnouncementSlide();
      case 7:
        return _buildDashboardPreviewSlide();
      default:
        return const SizedBox.shrink();
    }
  }

  // Slide 2: Dashboard Preview (OwnerDesignData)
  Widget _buildDashboardPreviewSlide() {
    return _buildSlideWrapper(
      headline: 'Sistem Terintegrasi RUMA',
      description:
          'Ketuk kartu metrik di dalam handphone mockup di bawah untuk memperbarui ringkasan data properti Anda.',
      visualChild: Container(
        width: 220,
        height: 320,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.lightBeige.withValues(alpha: 0.6), width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 12),
              blurRadius: 30,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: AppTheme.creamSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mock notch / status bar
                Container(
                  height: 16,
                  color: Colors.black12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                // Header brand
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.olive,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/RUMA LOGO 1.png',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RUMA',
                        style: GoogleFonts.poppins(
                          color: AppTheme.olive,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable preview
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        Text(
                          'Selamat datang,',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          OwnerDesignData.ownerName,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Metric Cards (2x2 grid)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.4,
                          children: List.generate(OwnerDesignData.metrics.length, (idx) {
                            final m = OwnerDesignData.metrics[idx];
                            return _previewMetricCard(m, idx);
                          }),
                        ),

                        const SizedBox(height: 10),

                        // Quick Actions
                        Text(
                          'Menu Utama',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: OwnerDesignData.actions.map((a) {
                            return _previewActionButton(a);
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                        // Room Cards mini list
                        Text(
                          'Kamar Terbaru',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...OwnerDesignData.rooms.map((r) => _previewRoomCard(r)),

                        const SizedBox(height: 10),

                        // Complaints mini list
                        Text(
                          'Keluhan Terbaru',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...OwnerDesignData.complaints.take(1).map((c) => _previewComplaintCard(c)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewMetricCard(OwnerMetric m, int index) {
    final isSelected = _selectedMetricIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetricIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.olive : AppTheme.border.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.olive.withValues(alpha: 0.1) : AppTheme.olive.withValues(alpha: 0.02),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.olive.withValues(alpha: 0.15) : AppTheme.olive.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                m.icon,
                color: AppTheme.olive,
                size: 11,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Dynamic display for interactive feel
                  index == 0 && _occupancyValue != 0.75
                      ? _occupancyLabel
                      : index == 2 && _complaintStatus != 'In Progress'
                          ? (_complaintStatus == 'Selesai' ? '0 Keluhan' : '1 Keluhan')
                          : m.value,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  m.label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 7,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewActionButton(OwnerAction a) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.olive.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
          ),
          child: Icon(a.icon, color: AppTheme.olive, size: 14),
        ),
        const SizedBox(height: 3),
        Text(
          a.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _previewRoomCard(OwnerRoomCard r) {
    final isOccupied = r.status == 'Terisi';
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.olive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.bed_rounded, color: AppTheme.olive, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamar ${r.roomNumber}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  r.boardingHouseName,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOccupied ? AppTheme.statusGreenBg : AppTheme.statusYellowBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.status,
                  style: TextStyle(
                    color: isOccupied ? AppTheme.statusGreenText : AppTheme.statusYellowText,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                r.price,
                style: GoogleFonts.poppins(
                  color: AppTheme.olive,
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewComplaintCard(OwnerComplaintCard c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.olive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.report_problem_outlined, color: AppTheme.olive, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${c.tenantName} • ${c.houseName}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 7,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: c.statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              c.status,
              style: TextStyle(
                color: c.statusTextColor,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Slide 0: Kelola Properti (overview) — fitur pertama
  Widget _buildWelcomeSlide() {
    return _buildSlideWrapper(
      headline: 'Kelola Properti Lebih Mudah',
      description:
          'Ketuk kartu logo RUMA di bawah untuk melihat interaksi animasi.',
      visualChild: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _welcomeTapCount.isEven ? 200 : 220,
            height: _welcomeTapCount.isEven ? 200 : 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightBeige.withValues(alpha: 0.08),
            ),
          ),
          // Elevated Logo Card
          GestureDetector(
            onTap: () {
              setState(() {
                _welcomeTapCount++;
              });
            },
            child: AnimatedScale(
              scale: _welcomeTapCount.isEven ? 1.0 : 1.1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.olive.withValues(alpha: 0.06),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/RUMA LOGO 1.png',
                  height: 80,
                  color: AppTheme.olive,
                ),
              ),
            ),
          ),
          // Floating Icon 1 (Top Left)
          Positioned(
            top: 24,
            left: 36,
            child: _buildFloatingBadge(
              icon: _welcomeTapCount % 2 == 0 ? Icons.trending_up : Icons.show_chart,
              color: AppTheme.accent,
            ),
          ),
          // Floating Icon 2 (Bottom Right)
          Positioned(
            bottom: 24,
            right: 36,
            child: _buildFloatingBadge(
              icon: _welcomeTapCount % 2 == 0 ? Icons.vpn_key_rounded : Icons.key_rounded,
              color: AppTheme.olive,
            ),
          ),
        ],
      ),
    );
  }

  // Slide 1: Occupancy
  Widget _buildOccupancySlide() {
    return _buildSlideWrapper(
      headline: 'Pantau Okupansi Real-time',
      description:
          'Ketuk grafik donut di bawah untuk mensimulasikan perubahan data okupansi kamar Anda.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_occupancyValue == 0.75) {
                  _occupancyValue = 0.90;
                  _occupancyLabel = '90%';
                } else if (_occupancyValue == 0.90) {
                  _occupancyValue = 0.50;
                  _occupancyLabel = '50%';
                } else {
                  _occupancyValue = 0.75;
                  _occupancyLabel = '75%';
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.olive.withValues(alpha: 0.08),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: _occupancyValue,
                      strokeWidth: 14,
                      backgroundColor: AppTheme.border.withValues(alpha: 0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.olive),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _occupancyLabel,
                        style: GoogleFonts.poppins(
                          color: AppTheme.olive,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'TERISI',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Floating active count (top right)
          Positioned(
            top: -12,
            right: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.olive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kamar Aktif: ${_occupancyValue == 0.75 ? 24 : _occupancyValue == 0.90 ? 29 : 16}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating waiting count (bottom left)
          Positioned(
            bottom: -12,
            left: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Menunggu: ${_occupancyValue == 0.75 ? 8 : _occupancyValue == 0.90 ? 3 : 16}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Room Management
  Widget _buildRoomSlide() {
    return _buildSlideWrapper(
      headline: 'Manajemen Kamar Praktis',
      description:
          'Ketuk kartu kamar di bawah untuk mengubah status ketersediaan unit kos Anda.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Room Card Mimic
          GestureDetector(
            onTap: () {
              setState(() {
                if (_roomStatus == 'Tersedia') {
                  _roomStatus = 'Terisi';
                  _roomStatusBg = AppTheme.statusYellowBg;
                  _roomStatusText = AppTheme.statusYellowText;
                } else {
                  _roomStatus = 'Tersedia';
                  _roomStatusBg = AppTheme.statusGreenBg;
                  _roomStatusText = AppTheme.statusGreenText;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.olive.withValues(alpha: 0.06),
                    offset: const Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Room Image placeholder
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFE5DEC9), Color(0xFFC8BE9E)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bed_rounded,
                        color: AppTheme.olive,
                        size: 40,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kamar A-102',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _roomStatusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _roomStatus,
                                style: TextStyle(
                                  color: _roomStatusText,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.wifi, size: 14, color: AppTheme.textSecondary),
                            SizedBox(width: 4),
                            Icon(Icons.ac_unit, size: 14, color: AppTheme.textSecondary),
                            SizedBox(width: 4),
                            Icon(Icons.bathroom, size: 14, color: AppTheme.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: AppTheme.border.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _roomStatus == 'Tersedia' ? 'Rp 2.400.000' : 'Rp 2.550.000',
                          style: GoogleFonts.poppins(
                            color: AppTheme.olive,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Edit Icon badge (Bottom Left)
          Positioned(
            bottom: -8,
            left: -14,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.olive,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          // Floating Galeri Photo badge (Top Right)
          Positioned(
            top: -12,
            right: -14,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: AppTheme.accent,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Tenant & Penagihan
  Widget _buildTenantSlide() {
    return _buildSlideWrapper(
      headline: 'Kelola Penghuni & Penagihan',
      description:
          'Ketuk badge tagihan di bawah untuk mengubah status pembayaran dari belum bayar menjadi lunas.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Tenant Profile Card
          GestureDetector(
            onTap: () {
              setState(() {
                if (_tenantBillingStatus == 'Belum Bayar') {
                  _tenantBillingStatus = 'Lunas';
                  _tenantBillingBg = AppTheme.statusGreenBg;
                  _tenantBillingText = AppTheme.statusGreenText;
                } else {
                  _tenantBillingStatus = 'Belum Bayar';
                  _tenantBillingBg = AppTheme.statusYellowBg;
                  _tenantBillingText = AppTheme.statusYellowText;
                }
              });
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.olive.withValues(alpha: 0.06),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.border.withValues(alpha: 0.6),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.olive,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ahmad Subarkah',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kamar 302',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Billing box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.creamSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'TGL',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '25',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.olive,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Billing Day',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Tiap tanggal 25',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _tenantBillingBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _tenantBillingStatus,
                        style: TextStyle(
                          color: _tenantBillingText,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 4: Automatic Payments
  Widget _buildPaymentSlide() {
    return _buildSlideWrapper(
      headline: 'Pembayaran Otomatis & Terpusat',
      description:
          'Ketuk resi pembayaran di bawah untuk mensimulasikan persetujuan status penagihan.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Payment Receipt Mimic
          GestureDetector(
            onTap: () {
              setState(() {
                if (_paymentStatus == 'BERHASIL') {
                  _paymentStatus = 'PENDING';
                  _paymentColor = AppTheme.accent;
                  _paymentIcon = Icons.sync_rounded;
                } else if (_paymentStatus == 'PENDING') {
                  _paymentStatus = 'DITOLAK';
                  _paymentColor = Colors.redAccent;
                  _paymentIcon = Icons.error_outline_rounded;
                } else {
                  _paymentStatus = 'BERHASIL';
                  _paymentColor = AppTheme.olive;
                  _paymentIcon = Icons.check_circle_outline_rounded;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 210,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.olive.withValues(alpha: 0.08),
                    offset: const Offset(0, 10),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkmark logo
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _paymentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _paymentIcon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: GoogleFonts.poppins(
                      color: _paymentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    child: Text(_paymentStatus),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _paymentStatus == 'DITOLAK' ? 'Rp 0' : 'Rp 2.500.000',
                    style: GoogleFonts.poppins(
                      color: AppTheme.olive,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Midtrans Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.creamSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 12,
                            color: AppTheme.olive,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Midtrans Secure',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Gateway Pembayaran',
                                style: TextStyle(
                                  fontSize: 7,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating sync bubble (Top Right)
          Positioned(
            top: -12,
            right: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.sync, color: Colors.white, size: 10),
                  SizedBox(width: 4),
                  Text(
                    'Real-time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 5: Integrated Complaints
  Widget _buildComplaintSlide() {
    return _buildSlideWrapper(
      headline: 'Solusi Komplain Terintegrasi',
      description:
          'Ketuk kartu komplain di bawah untuk memperbarui status dan penanganan keluhan secara real-time.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Complaint card
          GestureDetector(
            onTap: () {
              setState(() {
                if (_complaintStatus == 'In Progress') {
                  _complaintStatus = 'Selesai';
                  _complaintStatusBg = AppTheme.statusGreenBg;
                  _complaintStatusText = AppTheme.statusGreenText;
                  _complaintStepText = 'Perbaikan pipa selesai!';
                  _complaintStepIcon = Icons.check_circle_rounded;
                } else if (_complaintStatus == 'Selesai') {
                  _complaintStatus = 'Pending';
                  _complaintStatusBg = AppTheme.statusRedBg;
                  _complaintStatusText = AppTheme.statusRedText;
                  _complaintStepText = 'Menunggu verifikasi pemilik';
                  _complaintStepIcon = Icons.info_outline_rounded;
                } else {
                  _complaintStatus = 'In Progress';
                  _complaintStatusBg = AppTheme.statusBlueBg;
                  _complaintStatusText = AppTheme.statusBlueText;
                  _complaintStepText = 'Tukang dalam perjalanan';
                  _complaintStepIcon = Icons.directions_run_rounded;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 220,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.olive.withValues(alpha: 0.08),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pipa Bocor Kamar 302',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Lantai 3 • Ruma Kost',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _complaintStatusBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _complaintStatus,
                          style: TextStyle(
                            color: _complaintStatusText,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Small mock image
                  Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.plumbing_rounded,
                        color: AppTheme.olive,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Steps
                  Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          _complaintStepIcon,
                          key: ValueKey(_complaintStepIcon),
                          size: 12,
                          color: _complaintStatus == 'Pending' ? Colors.redAccent : AppTheme.olive,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _complaintStepText,
                            key: ValueKey(_complaintStepText),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Floating Verified user badge
          Positioned(
            top: -12,
            right: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.olive,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.white, size: 10),
                  SizedBox(width: 4),
                  Text(
                    'Transparan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 6: Announcements
  Widget _buildAnnouncementSlide() {
    return _buildSlideWrapper(
      headline: 'Informasi Cepat ke Penghuni',
      description:
          'Ketuk kartu pengumuman di bawah untuk mensimulasikan penyebaran informasi secara instan.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Mock announcement Card
          GestureDetector(
            onTap: () {
              setState(() {
                _announcementSent = !_announcementSent;
              });
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.olive.withValues(alpha: 0.08),
                    offset: const Offset(0, 10),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.olive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: AppTheme.olive,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PENGUMUMAN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              'Perbaikan Saluran Air',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.creamSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Perbaikan pipa air di lantai 2 sore ini pukul 15.00 WIB.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar mock stack
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppTheme.border,
                            child: Icon(Icons.person, size: 10, color: AppTheme.olive),
                          ),
                          SizedBox(width: 2),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppTheme.border,
                            child: Icon(Icons.person, size: 10, color: AppTheme.olive),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '+12 Penghuni',
                            style: TextStyle(fontSize: 8, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _announcementSent ? AppTheme.statusGreenBg : AppTheme.statusYellowBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _announcementSent ? 'Terkirim' : 'Kirim Ulang',
                          style: TextStyle(
                            color: _announcementSent ? AppTheme.statusGreenText : AppTheme.statusYellowText,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideWrapper({
    required String headline,
    required String description,
    required Widget visualChild,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Area (Bento / Card Canvas)
          Expanded(
            flex: 4,
            child: Center(
              child: visualChild,
            ),
          ),
          const SizedBox(height: 16),
          // Text Area
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppTheme.lightBeige,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppTheme.lightBeige.withValues(alpha: 0.75),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}
