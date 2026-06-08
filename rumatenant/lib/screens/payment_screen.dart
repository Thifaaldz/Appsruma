import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final room = tp.room;
    final boardingHouse = tp.boardingHouse;
    final pendingPayment = tp.pendingPayment;
    final roomPrice = room?.price ?? boardingHouse?.defaultRoomPrice ?? 0;
    final now = DateTime.now();
    final currentPeriod = DateFormat('MMMM yyyy', 'id_ID').format(now);

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
                                  ? AppTheme.statusYellowBg
                                  : AppTheme.statusMintBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              pendingPayment != null
                                  ? Icons.access_time
                                  : Icons.check_circle_outline,
                              color: pendingPayment != null
                                  ? AppTheme.statusYellowText
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
                                _DetailLine(
                                  label: 'Periode',
                                  value: currentPeriod,
                                ),
                                _DetailLine(
                                  label: 'Tagihan',
                                  value: _formatCurrency(billAmount),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
                    ],
                  ],
                ),
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

    final Uri url = Uri.parse(redirectUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) {
        _showStatusCheckDialog(orderId);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka link pembayaran.'),
            backgroundColor: Color(0xFFB23A48),
          ),
        );
      }
    }
  }

  void _showStatusCheckDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _StatusCheckDialog(orderId: orderId);
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
  const _StatusCheckDialog({required this.orderId});

  final String orderId;

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
      // Find updated payment status in provider
      final isPaid = provider.payments.any((p) => p.status == 'paid');
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
