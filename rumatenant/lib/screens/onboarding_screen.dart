import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../data/tenant_design_data.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7;

  // Interactive slide states
  int _welcomeTapCount = 0;
  
  // Slide 1: Room Info State
  String _billingStatus = 'Belum Bayar';
  Color _billingStatusBg = AppTheme.statusYellowBg;
  Color _billingStatusText = AppTheme.statusYellowText;

  // Slide 2: Midtrans Payment State
  String _paymentStatus = 'PENDING';
  Color _paymentColor = AppTheme.statusYellowText;
  Color _paymentBg = AppTheme.statusYellowBg;
  int _selectedPaymentMethod = 0;

  // Slide 3: Pay Next Month State
  bool _isAdvancePaid = false;

  // Slide 4: Complaint State
  String _complaintStatus = 'Pending';
  Color _complaintStatusBg = AppTheme.statusRedBg;
  Color _complaintStatusText = AppTheme.statusRedText;
  String _complaintStepText = 'Menunggu verifikasi pemilik';
  IconData _complaintStepIcon = Icons.info_outline_rounded;

  // Slide 5: Announcement State
  bool _announcementRead = false;

  // Slide 6: Dashboard State
  int _selectedMetricIndex = 0;

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
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sec) => const LoginScreen(),
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
                      onPressed: _goToLogin,
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

              // Page Content
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

              // Footer
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

                    // Action Buttons
                    Row(
                      children: [
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
                                      ? 'Mulai Aplikasi'
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
        return _buildRoomSlide();
      case 2:
        return _buildPaymentSlide();
      case 3:
        return _buildPayNextMonthSlide();
      case 4:
        return _buildComplaintSlide();
      case 5:
        return _buildAnnouncementSlide();
      case 6:
        return _buildDashboardPreviewSlide();
      default:
        return const SizedBox.shrink();
    }
  }

  // Slide 0: Welcome / Pengenalan
  Widget _buildWelcomeSlide() {
    return _buildSlideWrapper(
      headline: 'Aplikasi Penghuni RUMA',
      description:
          'Ketuk kartu logo RUMA di bawah untuk melihat interaksi animasi.',
      visualChild: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _welcomeTapCount.isEven ? 200 : 220,
            height: _welcomeTapCount.isEven ? 200 : 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightBeige.withValues(alpha: 0.08),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _welcomeTapCount++;
              });
            },
            child: AnimatedScale(
              scale: _welcomeTapCount.isEven ? 1.0 : 1.08,
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.lightBeige.withValues(alpha: 0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.olive.withValues(alpha: 0.15),
                      offset: const Offset(0, 10),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/RUMA LOGO 1.png',
                    height: 64,
                    color: AppTheme.olive,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedRotation(
              turns: _welcomeTapCount * 0.125,
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_outlined, color: AppTheme.olive, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 1: Room & Bill Info
  Widget _buildRoomSlide() {
    return _buildSlideWrapper(
      headline: 'Dashboard Ringkasan Kamar',
      description:
          'Ketuk kartu status di bawah untuk memperbarui status tagihan kost bulanan Anda.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
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
                            TenantDesignData.roomLabel,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Lantai 1 • Properti RUMA',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_billingStatus == 'Belum Bayar') {
                            _billingStatus = 'Lunas';
                            _billingStatusBg = AppTheme.statusGreenBg;
                            _billingStatusText = AppTheme.statusGreenText;
                          } else {
                            _billingStatus = 'Belum Bayar';
                            _billingStatusBg = AppTheme.statusYellowBg;
                            _billingStatusText = AppTheme.statusYellowText;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _billingStatusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _billingStatus,
                          style: TextStyle(
                            color: _billingStatusText,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya Bulanan',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    Text(
                      TenantDesignData.monthlyBill,
                      style: GoogleFonts.poppins(
                        color: AppTheme.olive,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jatuh Tempo',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    Text(
                      TenantDesignData.dueDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Midtrans payment
  Widget _buildPaymentSlide() {
    return _buildSlideWrapper(
      headline: 'Pembayaran Tagihan Terintegrasi',
      description:
          'Pilih metode pembayaran di bawah untuk mensimulasikan transaksi pembayaran Midtrans Snap.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MIDTRANS SNAP',
                      style: GoogleFonts.poppins(
                        color: AppTheme.olive,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _paymentBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _paymentStatus,
                        style: TextStyle(
                          color: _paymentColor,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(TenantDesignData.paymentMethods.length, (idx) {
                  final pm = TenantDesignData.paymentMethods[idx];
                  final isSelected = _selectedPaymentMethod == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = idx;
                        _paymentStatus = 'PROSES...';
                        _paymentColor = AppTheme.statusBlueText;
                        _paymentBg = AppTheme.statusBlueBg;
                      });
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) {
                          setState(() {
                            _paymentStatus = 'BERHASIL';
                            _paymentColor = AppTheme.statusMintText;
                            _paymentBg = AppTheme.statusMintBg;
                          });
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.olive.withValues(alpha: 0.06) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.olive : AppTheme.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(pm.icon, color: AppTheme.olive, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pm.title,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  pm.subtitle,
                                  style: const TextStyle(fontSize: 7, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppTheme.olive, size: 12),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Pay Next Month
  Widget _buildPayNextMonthSlide() {
    return _buildSlideWrapper(
      headline: 'Bayar Bulan Depan Lebih Awal',
      description:
          'Ketuk tombol pembayaran di bawah untuk mensimulasikan pembayaran sewa di muka.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isAdvancePaid ? 'Mei 2026' : 'April 2026',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _isAdvancePaid ? AppTheme.statusGreenBg : AppTheme.statusYellowBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isAdvancePaid ? 'Lunas (Advance)' : 'Belum Bayar',
                        style: TextStyle(
                          color: _isAdvancePaid ? AppTheme.statusGreenText : AppTheme.statusYellowText,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _isAdvancePaid
                      ? 'Terima kasih! Anda telah membayar uang sewa untuk periode bulan berikutnya lebih awal.'
                      : 'Bayar sewa bulan berikutnya lebih cepat untuk kepastian hunian Anda.',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAdvancePaid = !_isAdvancePaid;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAdvancePaid ? Colors.grey[300] : AppTheme.olive,
                      foregroundColor: _isAdvancePaid ? Colors.black54 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      _isAdvancePaid ? 'Batalkan Pembayaran' : 'Bayar Bulan Depan',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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

  // Slide 4: Complaints
  Widget _buildComplaintSlide() {
    return _buildSlideWrapper(
      headline: 'Pelaporan Keluhan Fasilitas',
      description:
          'Ketuk kartu komplain untuk mensimulasikan pergantian status tindak lanjut keluhan kamar.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_complaintStatus == 'Pending') {
                  _complaintStatus = 'Diproses';
                  _complaintStatusBg = AppTheme.statusBlueBg;
                  _complaintStatusText = AppTheme.statusBlueText;
                  _complaintStepText = 'Tukang sedang menuju kos';
                  _complaintStepIcon = Icons.directions_run_rounded;
                } else if (_complaintStatus == 'Diproses') {
                  _complaintStatus = 'Selesai';
                  _complaintStatusBg = AppTheme.statusGreenBg;
                  _complaintStatusText = AppTheme.statusGreenText;
                  _complaintStepText = 'Perbaikan AC telah selesai';
                  _complaintStepIcon = Icons.check_circle_rounded;
                } else {
                  _complaintStatus = 'Pending';
                  _complaintStatusBg = AppTheme.statusRedBg;
                  _complaintStatusText = AppTheme.statusRedText;
                  _complaintStepText = 'Menunggu verifikasi pemilik';
                  _complaintStepIcon = Icons.info_outline_rounded;
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
                              'AC Kamar Kurang Dingin',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Kamar A1 • Ruma Kost',
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
                  Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.ac_unit_rounded,
                        color: AppTheme.olive,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
        ],
      ),
    );
  }

  // Slide 5: Announcements
  Widget _buildAnnouncementSlide() {
    return _buildSlideWrapper(
      headline: 'Pengumuman Terintegrasi',
      description:
          'Ketuk kartu pengumuman di bawah untuk menandai sebagai telah dibaca.',
      visualChild: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _announcementRead = !_announcementRead;
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
                              'PENGUMUMAN KOST',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              'Pemeliharaan Air Bersih',
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
                      'Akan ada pemeliharaan pipa air bersih besok pagi pukul 09.00 - 11.00 WIB.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _announcementRead ? AppTheme.statusGreenBg : AppTheme.statusYellowBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _announcementRead ? 'Selesai Dibaca' : 'Belum Dibaca',
                          style: TextStyle(
                            color: _announcementRead ? AppTheme.statusGreenText : AppTheme.statusYellowText,
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

  // Slide 6: Integrated Dashboard
  Widget _buildDashboardPreviewSlide() {
    return _buildSlideWrapper(
      headline: 'Sistem Terintegrasi Tenant',
      description:
          'Ketuk kartu metrik di dalam handphone mockup di bawah untuk memperbarui ringkasan data kost Anda.',
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
                          'Halo Penghuni,',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          TenantDesignData.name,
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
                          children: [
                            _previewMetricCard('Kamar Sewa', TenantDesignData.roomNumber, Icons.meeting_room, 0),
                            _previewMetricCard('Tagihan', _isAdvancePaid ? 'Lunas' : TenantDesignData.monthlyBill, Icons.receipt_long, 1),
                            _previewMetricCard('Keluhan', _complaintStatus == 'Selesai' ? '0 Keluhan' : '1 Keluhan', Icons.report_problem, 2),
                            _previewMetricCard('Pengumuman', _announcementRead ? '0 Baru' : '1 Baru', Icons.campaign, 3),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Quick Actions
                        Text(
                          'Menu Cepat',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _previewActionButton(Icons.credit_card, 'Bayar'),
                            _previewActionButton(Icons.report_problem, 'Keluhan'),
                            _previewActionButton(Icons.history, 'Riwayat'),
                            _previewActionButton(Icons.person, 'Profil'),
                          ],
                        ),
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

  Widget _previewMetricCard(String label, String value, IconData icon, int index) {
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
                icon,
                color: AppTheme.olive,
                size: 11,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
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

  Widget _previewActionButton(IconData icon, String label) {
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
          child: Icon(icon, color: AppTheme.olive, size: 14),
        ),
        const SizedBox(height: 3),
        Text(
          label,
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

  // Common wrapper for onboarding slide layouts
  Widget _buildSlideWrapper({
    required String headline,
    required String description,
    required Widget visualChild,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final isSmallScreen = height < 480;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: isSmallScreen ? 3 : 5,
                child: Center(
                  child: visualChild,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.lightBeige,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppTheme.lightBeige.withValues(alpha: 0.8),
                    fontSize: isSmallScreen ? 12 : 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
