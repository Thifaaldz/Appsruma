import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';
import 'midtrans_webview_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final room = tp.room;
    final boardingHouse = tp.boardingHouse;
    final pendingPayment = tp.pendingPayment;
    final allPaid = tp.allPaid;
    final roomPrice = room?.price ?? boardingHouse?.defaultRoomPrice ?? 0;

    final billAmount = pendingPayment?.amount ?? roomPrice;

    return SafeArea(
      bottom: false,
      child: tp.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.olive))
          : RefreshIndicator(
              onRefresh: () => tp.refresh(),
              color: AppTheme.olive,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const RumaBrandLogo(height: 22),
                    const SizedBox(height: 34),
                    const RumaPageTitle(title: 'Pembayaran'),
                    const SizedBox(height: 28),
                    const RumaSectionHeader(title: 'Detail Tagihan'),
                    const SizedBox(height: 8),
                    RumaPanel(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: pendingPayment != null
                                  ? (pendingPayment.isOverdue
                                      ? const Color(0xFFFDE8E8)
                                      : AppTheme.statusYellowBg)
                                  : AppTheme.statusMintBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              pendingPayment != null
                                  ? (pendingPayment.isOverdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.access_time)
                                  : Icons.check_circle_outline,
                              color: pendingPayment != null
                                  ? (pendingPayment.isOverdue
                                      ? const Color(0xFFB23A48)
                                      : AppTheme.statusYellowText)
                                  : AppTheme.statusGreenText,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: [
                                _DetailLine(
                                  label: 'Kamar',
                                  value: room?.roomNumber ?? '-',
                                ),
                                _DetailLine(
                                  label: 'Kos',
                                  value: boardingHouse?.name ?? '-',
                                ),
                                if (pendingPayment != null) ...[
                                  _DetailLine(
                                    label: 'Periode',
                                    value: pendingPayment.billingPeriod.isNotEmpty
                                        ? pendingPayment.billingPeriod
                                        : '-',
                                  ),
                                  _DetailLine(
                                    label: 'Jatuh Tempo',
                                    value: _formatDate(pendingPayment.dueDate),
                                  ),
                                  _DetailLine(
                                    label: 'Batas Overdue',
                                    value: _formatDate(pendingPayment.overdueDate),
                                  ),
                                ],
                                _DetailLine(
                                  label: 'Tagihan',
                                  value: _formatCurrency(billAmount),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (pendingPayment != null && pendingPayment.isOverdue)
                                      RumaStatusChip(
                                        label: 'Overdue',
                                        backgroundColor: const Color(0xFFFDE8E8),
                                        textColor: const Color(0xFFB23A48),
                                      )
                                    else
                                      RumaStatusChip(
                                        label: pendingPayment != null
                                            ? 'Belum Bayar'
                                            : 'Lunas',
                                        backgroundColor: pendingPayment != null
                                            ? AppTheme.statusYellowBg
                                            : AppTheme.statusGreenBg,
                                        textColor: pendingPayment != null
                                            ? AppTheme.statusYellowText
                                            : AppTheme.statusGreenText,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Overdue warning
                    if (pendingPayment != null && pendingPayment.isOverdue) ...[
                      const SizedBox(height: 12),
                      RumaPanel(
                        backgroundColor: const Color(0xFFFDE8E8),
                        borderColor: const Color(0xFFF5C6CB),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              color: Color(0xFFB23A48),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tagihan Anda sudah melewati batas jatuh tempo! Segera lakukan pembayaran.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFB23A48),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (pendingPayment != null) ...[
                      const SizedBox(height: 16),
                      const RumaSectionHeader(title: 'Metode Pembayaran (Midtrans Snap)'),
                      const SizedBox(height: 8),
                      RumaPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total yang harus dibayar',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatCurrency(pendingPayment.amount),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            if (pendingPayment.daysUntilOverdue > 0)
                              Text(
                                'Sisa ${pendingPayment.daysUntilOverdue} hari sebelum overdue',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: pendingPayment.daysUntilOverdue <= 3
                                          ? const Color(0xFFB23A48)
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Pembayaran aman dan otomatis menggunakan gerbang pembayaran Midtrans Sandbox.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            _MidtransPayButton(
                              paymentId: pendingPayment.id,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 24),
                      RumaPanel(
                        backgroundColor: AppTheme.statusMintBg,
                        borderColor: AppTheme.statusMintBg,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.statusGreenText,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tidak ada tagihan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.statusGreenText,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Semua tagihan Anda sudah lunas. 🎉',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.statusGreenText,
                                          fontSize: 13,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // "Bayar Bulan Depan" button - only show when all bills are paid
                      if (allPaid) ...[
                        const SizedBox(height: 16),
                        const RumaSectionHeader(title: 'Bayar di Muka'),
                        const SizedBox(height: 8),
                        RumaPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingin bayar bulan depan sekarang?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Anda bisa membayar tagihan bulan depan di muka agar tidak perlu khawatir.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              const _PayNextMonthButton(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class _PayNextMonthButton extends StatefulWidget {
  const _PayNextMonthButton();

  @override
  State<_PayNextMonthButton> createState() => _PayNextMonthButtonState();
}

class _PayNextMonthButtonState extends State<_PayNextMonthButton> {
  bool _isLoading = false;

  Future<void> _handlePayNextMonth() async {
    setState(() => _isLoading = true);

    final provider = context.read<TenantProvider>();
    final result = await provider.payNextMonth();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result != null && result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Gagal membuat tagihan bulan depan'),
          backgroundColor: const Color(0xFFB23A48),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan bulan depan berhasil dibuat! Silakan bayar.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handlePayNextMonth,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.olive,
                ),
              )
            : const Icon(Icons.calendar_month_outlined, color: AppTheme.olive),
        label: Text(
          _isLoading ? 'Memproses...' : 'Bayar Bulan Depan',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.olive,
                fontWeight: FontWeight.w700,
              ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.olive,
          side: const BorderSide(color: AppTheme.olive, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _MidtransPayButton extends StatefulWidget {
  const _MidtransPayButton({required this.paymentId});

  final int paymentId;

  @override
  State<_MidtransPayButton> createState() => _MidtransPayButtonState();
}

class _MidtransPayButtonState extends State<_MidtransPayButton> {
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    final provider = context.read<TenantProvider>();
    final snapData = await provider.getMidtransSnapToken(widget.paymentId);

    setState(() => _isLoading = false);

    if (snapData == null || snapData['redirect_url'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendapatkan token transaksi Midtrans.'),
            backgroundColor: Color(0xFFB23A48),
          ),
        );
      }
      return;
    }

    final String redirectUrl = snapData['redirect_url'];
    final String orderId = snapData['order_id'];

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransWebViewScreen(
          url: redirectUrl,
          orderId: orderId,
        ),
      ),
    );

    if (mounted) {
      _showStatusCheckDialog(orderId, widget.paymentId);
    }
  }

  void _showStatusCheckDialog(String orderId, int paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _StatusCheckDialog(orderId: orderId, paymentId: paymentId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handlePayment,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.payment_outlined, color: Colors.white),
        label: Text(
          _isLoading ? 'Memproses...' : 'Bayar Sekarang',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.olive,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _StatusCheckDialog extends StatefulWidget {
  const _StatusCheckDialog({
    required this.orderId,
    required this.paymentId,
  });

  final String orderId;
  final int paymentId;

  @override
  State<_StatusCheckDialog> createState() => _StatusCheckDialogState();
}

class _StatusCheckDialogState extends State<_StatusCheckDialog> {
  bool _isChecking = false;
  String _message = 'Selesaikan pembayaran pada halaman Midtrans yang telah terbuka.';

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
      _message = 'Menghubungi server Midtrans...';
    });

    final provider = context.read<TenantProvider>();
    final success = await provider.checkPaymentStatus(widget.orderId);

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (success) {
      // Find updated payment status in provider for this specific bill
      final isPaid = provider.payments.any((p) => p.id == widget.paymentId && p.status == 'paid');
      if (isPaid) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran Sukses Terverifikasi! ✅'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        return;
      }
    }

    setState(() {
      _message = 'Pembayaran belum terdeteksi. Silakan selesaikan pembayaran atau coba periksa kembali.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Menunggu Pembayaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(color: AppTheme.olive),
          ),
          const SizedBox(height: 16),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: _isChecking ? null : _checkStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.olive,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cek Status Pembayaran'),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
