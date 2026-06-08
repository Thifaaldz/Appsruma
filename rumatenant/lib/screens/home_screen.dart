import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onPayNow,
    required this.onOpenHistory,
  });

  final VoidCallback onPayNow;
  final VoidCallback onOpenHistory;

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
    final user = tp.user;
    final room = tp.room;
    final boardingHouse = tp.boardingHouse;
    final payments = tp.payments;

    final userName = user?.name ?? 'Penghuni';
    final roomPrice = room?.price ?? boardingHouse?.defaultRoomPrice ?? 0;
    final monthlyBill = _formatCurrency(roomPrice);

    // Calculate current billing period
    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM yyyy', 'id_ID').format(now);

    // Check if there's an unpaid payment this month
    final hasPendingPayment = payments.any((p) =>
        p.status == 'pending' || p.status == 'Belum Bayar');

    // Find the latest paid payment for the history section
    final paidPayments = payments.where((p) =>
        p.status == 'paid' || p.status == 'Lunas').toList();
    final latestPaid = paidPayments.isNotEmpty ? paidPayments.first : null;

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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RumaBrandLogo(height: 22),
                    const SizedBox(height: 44),
                    Text(
                      'Halo, $userName',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola pembayaran kosmu dengan mudah',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    RumaPanel(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagihan Bulan Ini',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentMonth,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textMuted,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            monthlyBill,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'Kamar :',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                room?.roomNumber ?? '-',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                boardingHouse?.name ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: RumaStatusChip(
                              label: hasPendingPayment ? 'Belum Bayar' : 'Lunas',
                              backgroundColor: hasPendingPayment
                                  ? AppTheme.statusYellowBg
                                  : AppTheme.statusGreenBg,
                              textColor: hasPendingPayment
                                  ? AppTheme.statusYellowText
                                  : AppTheme.statusGreenText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    RumaPanel(
                      backgroundColor: const Color(0xFFBBDDC0),
                      borderColor: const Color(0xFFBBDDC0),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3AD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.home_outlined,
                              color: AppTheme.olive,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  boardingHouse?.name ?? 'Kos Anda',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kamar ${room?.roomNumber ?? '-'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  boardingHouse?.address ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: 12,
                                        color: AppTheme.textDark,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    RumaPrimaryButton(label: 'Bayar Sekarang', onPressed: onPayNow),
                    const SizedBox(height: 18),
                    if (payments.isNotEmpty) ...[
                      RumaSectionHeader(
                        title: 'Riwayat Terakhir',
                        actionLabel: 'Lihat Semua',
                        onAction: onOpenHistory,
                      ),
                      const SizedBox(height: 10),
                      _RecentHistoryCard(
                        payment: latestPaid ?? payments.first,
                        formatCurrency: _formatCurrency,
                      ),
                    ],
                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RecentHistoryCard extends StatelessWidget {
  const _RecentHistoryCard({
    required this.payment,
    required this.formatCurrency,
  });

  final dynamic payment;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status == 'paid' || payment.status == 'Lunas';

    String periodLabel = '';
    try {
      final date = DateTime.parse(payment.paymentDate);
      periodLabel = DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      periodLabel = payment.paymentDate;
    }

    return RumaPanel(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPaid ? AppTheme.statusMintBg : AppTheme.statusYellowBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_outline : Icons.access_time,
              size: 20,
              color: isPaid ? AppTheme.statusGreenText : AppTheme.statusYellowText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              periodLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            formatCurrency(payment.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          RumaStatusChip(
            label: isPaid ? 'Lunas' : 'Belum Bayar',
            backgroundColor:
                isPaid ? AppTheme.statusGreenBg : AppTheme.statusYellowBg,
            textColor:
                isPaid ? AppTheme.statusGreenText : AppTheme.statusYellowText,
          ),
        ],
      ),
    );
  }
}
