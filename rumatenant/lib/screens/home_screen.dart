import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/complaint.dart';
import '../models/payment.dart';
import '../providers/complaint_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ComplaintProvider>().fetchComplaints();
      }
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  DateTime _paymentSortDate(Payment payment) {
    for (final value in [
      payment.paidAt,
      payment.paymentDate,
      payment.dueDate,
      payment.createdAt,
    ]) {
      if (value == null || value.isEmpty) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _mapComplaintStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('done') || normalized.contains('selesai')) {
      return 'Selesai';
    }
    if (normalized.contains('process') ||
        normalized.contains('proses') ||
        normalized.contains('progress')) {
      return 'Diproses';
    }
    return 'Menunggu';
  }

  Color _complaintStatusBackground(String status) {
    final label = _mapComplaintStatus(status);
    if (label == 'Selesai') return AppTheme.statusGreenBg;
    if (label == 'Diproses') return AppTheme.statusBlueBg;
    return AppTheme.statusYellowBg;
  }

  Color _complaintStatusTextColor(String status) {
    final label = _mapComplaintStatus(status);
    if (label == 'Selesai') return AppTheme.statusGreenText;
    if (label == 'Diproses') return AppTheme.statusBlueText;
    return AppTheme.statusYellowText;
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final user = tp.user;
    final room = tp.room;
    final boardingHouse = tp.boardingHouse;
    final payments = tp.payments;
    final complaints = [...complaintProvider.complaints]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final userName = user?.name ?? 'Penghuni';
    final roomPrice = room?.price ?? boardingHouse?.defaultRoomPrice ?? 0;
    final monthlyBill = _formatCurrency(roomPrice);

    // Use billing period from pending payment if available
    final pendingPay = tp.pendingPayment;
    final now = DateTime.now();
    final currentMonth =
        pendingPay != null && pendingPay.billingPeriod.isNotEmpty
        ? pendingPay.billingPeriod
        : DateFormat('MMMM yyyy', 'id_ID').format(now);

    // Check if there's an unpaid payment
    final hasPendingPayment = payments.any(
      (p) => p.status == 'pending' || p.status == 'overdue',
    );
    final hasOverdue = payments.any((p) => p.status == 'overdue');

    final recentHistoryItems = [
      ...payments
          .take(3)
          .map(
            (payment) =>
                _RecentHistoryEntry.payment(payment, _paymentSortDate(payment)),
          ),
      ...complaints
          .take(3)
          .map((complaint) => _RecentHistoryEntry.complaint(complaint)),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final visibleRecentHistory = recentHistoryItems.take(3).toList();

    return SafeArea(
      bottom: false,
      child: tp.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.olive),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  context.read<TenantProvider>().refresh(),
                  context.read<ComplaintProvider>().fetchComplaints(),
                ]);
              },
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
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontSize: 28, fontWeight: FontWeight.w800),
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
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentMonth,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textMuted,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            monthlyBill,
                            style: Theme.of(context).textTheme.displayMedium
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
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                room?.roomNumber ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                boardingHouse?.name ?? '',
                                style: Theme.of(context).textTheme.bodyMedium
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kamar ${room?.roomNumber ?? '-'}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  boardingHouse?.address ?? '',
                                  style: Theme.of(context).textTheme.bodySmall
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
                    RumaPrimaryButton(
                      label: 'Bayar Sekarang',
                      onPressed: widget.onPayNow,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: widget.onOpenComplaint,
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
                        onAction: widget.onOpenNotifications,
                      ),
                      const SizedBox(height: 10),
                      ...tp.announcements
                          .take(2)
                          .map(
                            (ann) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RumaPanel(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F4FD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.campaign_outlined,
                                        size: 18,
                                        color: AppTheme.textDark,
                                      ),
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
                            ),
                          ),
                    ],
                    const SizedBox(height: 8),
                    if (visibleRecentHistory.isNotEmpty) ...[
                      RumaSectionHeader(
                        title: 'Riwayat Terakhir',
                        actionLabel: 'Lihat Semua',
                        onAction: widget.onOpenHistory,
                      ),
                      const SizedBox(height: 10),
                      RumaPanel(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: visibleRecentHistory.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                _RecentHistoryRow(
                                  item: item,
                                  formatCurrency: _formatCurrency,
                                  mapComplaintStatus: _mapComplaintStatus,
                                  complaintStatusBackground:
                                      _complaintStatusBackground,
                                  complaintStatusTextColor:
                                      _complaintStatusTextColor,
                                ),
                                if (index != visibleRecentHistory.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ),
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

class _RecentHistoryEntry {
  const _RecentHistoryEntry._({
    this.payment,
    this.complaint,
    required this.date,
  });

  factory _RecentHistoryEntry.payment(Payment payment, DateTime date) {
    return _RecentHistoryEntry._(payment: payment, date: date);
  }

  factory _RecentHistoryEntry.complaint(Complaint complaint) {
    return _RecentHistoryEntry._(
      complaint: complaint,
      date: complaint.createdAt,
    );
  }

  final Payment? payment;
  final Complaint? complaint;
  final DateTime date;
}

class _RecentHistoryRow extends StatelessWidget {
  const _RecentHistoryRow({
    required this.item,
    required this.formatCurrency,
    required this.mapComplaintStatus,
    required this.complaintStatusBackground,
    required this.complaintStatusTextColor,
  });

  final _RecentHistoryEntry item;
  final String Function(double) formatCurrency;
  final String Function(String) mapComplaintStatus;
  final Color Function(String) complaintStatusBackground;
  final Color Function(String) complaintStatusTextColor;

  @override
  Widget build(BuildContext context) {
    final payment = item.payment;
    final complaint = item.complaint;

    if (payment != null) {
      final isPaid = payment.status == 'paid' || payment.status == 'Lunas';
      final isOverdue = payment.status == 'overdue';
      final statusLabel = isOverdue
          ? 'Overdue'
          : isPaid
          ? 'Lunas'
          : 'Belum Bayar';

      String periodLabel = payment.billingPeriod;
      if (periodLabel.isEmpty) {
        try {
          final date = DateTime.parse(
            payment.paymentDate.isNotEmpty
                ? payment.paymentDate
                : payment.dueDate,
          );
          periodLabel = DateFormat('MMMM yyyy', 'id_ID').format(date);
        } catch (_) {
          periodLabel = payment.paymentDate.isNotEmpty
              ? payment.paymentDate
              : '-';
        }
      }

      return _RecentHistoryTile(
        icon: isOverdue
            ? Icons.warning_amber_rounded
            : isPaid
            ? Icons.check_circle_outline
            : Icons.access_time,
        iconBackground: isOverdue
            ? const Color(0xFFFDE8E8)
            : isPaid
            ? AppTheme.statusMintBg
            : AppTheme.statusYellowBg,
        iconColor: isOverdue
            ? const Color(0xFFB23A48)
            : isPaid
            ? AppTheme.statusGreenText
            : AppTheme.statusYellowText,
        title: periodLabel,
        subtitle: formatCurrency(payment.amount),
        chipLabel: statusLabel,
        chipBackground: isOverdue
            ? const Color(0xFFFDE8E8)
            : isPaid
            ? AppTheme.statusGreenBg
            : AppTheme.statusYellowBg,
        chipTextColor: isOverdue
            ? const Color(0xFFB23A48)
            : isPaid
            ? AppTheme.statusGreenText
            : AppTheme.statusYellowText,
      );
    }

    final statusLabel = mapComplaintStatus(complaint!.status);
    final createdLabel = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(complaint.createdAt);

    IconData icon = Icons.hourglass_empty_rounded;
    if (statusLabel == 'Diproses') icon = Icons.build_circle_outlined;
    if (statusLabel == 'Selesai') icon = Icons.check_circle_outline;

    return _RecentHistoryTile(
      icon: icon,
      iconBackground: complaintStatusBackground(complaint.status),
      iconColor: complaintStatusTextColor(complaint.status),
      title: 'Keluhan: ${complaint.title}',
      subtitle: complaint.description.isNotEmpty
          ? '${complaint.description} - $createdLabel'
          : createdLabel,
      chipLabel: statusLabel,
      chipBackground: complaintStatusBackground(complaint.status),
      chipTextColor: complaintStatusTextColor(complaint.status),
    );
  }
}

class _RecentHistoryTile extends StatelessWidget {
  const _RecentHistoryTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.chipBackground,
    required this.chipTextColor,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String chipLabel;
  final Color chipBackground;
  final Color chipTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 0,
            child: RumaStatusChip(
              label: chipLabel,
              backgroundColor: chipBackground,
              textColor: chipTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
