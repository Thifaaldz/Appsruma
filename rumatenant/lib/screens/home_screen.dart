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
    required this.onOpenComplaint,
    required this.onOpenNotifications,
  });

  final VoidCallback onPayNow;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenComplaint;
  final VoidCallback onOpenNotifications;

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

    // Use billing period from pending payment if available
    final pendingPay = tp.pendingPayment;
    final now = DateTime.now();
    final currentMonth = pendingPay != null && pendingPay.billingPeriod.isNotEmpty
        ? pendingPay.billingPeriod
        : DateFormat('MMMM yyyy', 'id_ID').format(now);

    // Check if there's an unpaid payment
    final hasPendingPayment = payments.any((p) =>
        p.status == 'pending' || p.status == 'overdue');
    final hasOverdue = payments.any((p) => p.status == 'overdue');

    // Find the latest paid payment for the history section
    final paidPayments = payments.where((p) =>
        p.status == 'paid').toList();
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
                              label: hasOverdue
                                  ? 'Overdue'
                                  : hasPendingPayment
                                      ? 'Belum Bayar'
                                      : 'Lunas',
                              backgroundColor: hasOverdue
                                  ? const Color(0xFFFDE8E8)
                                  : hasPendingPayment
                                      ? AppTheme.statusYellowBg
                                      : AppTheme.statusGreenBg,
                              textColor: hasOverdue
                                  ? const Color(0xFFB23A48)
                                  : hasPendingPayment
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
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onOpenComplaint,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.olive, width: 2),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Laporkan Keluhan',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.olive,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (tp.announcements.isNotEmpty) ...[
                      RumaSectionHeader(
                        title: 'Notifikasi & Pengumuman',
                        actionLabel: 'Lihat Semua',
                        onAction: onOpenNotifications,
                      ),
                      const SizedBox(height: 10),
                      ...tp.announcements.take(2).map((ann) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RumaPanel(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F4FD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.campaign_outlined,
                                        size: 18, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ann.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          ann.content,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme.textDark,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                    const SizedBox(height: 8),
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
