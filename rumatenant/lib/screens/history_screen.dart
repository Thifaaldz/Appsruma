import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/payment.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Semua';

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _mapStatusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'paid') return 'Lunas';
    if (s == 'pending') return 'Belum Bayar';
    if (s == 'overdue') return 'Overdue';
    if (s == 'cancelled') return 'Dibatalkan';
    return status;
  }

  bool _isPaid(String status) {
    return status.toLowerCase() == 'paid';
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final payments = tp.payments;

    final visibleItems = payments.where((item) {
      final label = _mapStatusLabel(item.status);
      if (_selectedFilter == 'Lunas') return label == 'Lunas';
      if (_selectedFilter == 'Belum Bayar') return label == 'Belum Bayar' || label == 'Overdue';
      return true;
    }).toList();

    return SafeArea(
      bottom: false,
      child: tp.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.olive))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RumaBrandLogo(height: 22),
                  const SizedBox(height: 34),
                  const RumaPageTitle(title: 'Riwayat Pembayaran'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RumaFilterChip(
                        label: 'Semua',
                        selected: _selectedFilter == 'Semua',
                        onTap: () => setState(() => _selectedFilter = 'Semua'),
                      ),
                      RumaFilterChip(
                        label: 'Lunas',
                        selected: _selectedFilter == 'Lunas',
                        onTap: () => setState(() => _selectedFilter = 'Lunas'),
                      ),
                      RumaFilterChip(
                        label: 'Belum Bayar',
                        selected: _selectedFilter == 'Belum Bayar',
                        onTap: () =>
                            setState(() => _selectedFilter = 'Belum Bayar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (visibleItems.isEmpty)
                    RumaPanel(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat pembayaran',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    RumaPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: visibleItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            children: [
                              _HistoryItemRow(
                                item: item,
                                formatCurrency: _formatCurrency,
                                mapStatusLabel: _mapStatusLabel,
                                isPaid: _isPaid,
                              ),
                              if (index != visibleItems.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _HistoryItemRow extends StatelessWidget {
  const _HistoryItemRow({
    required this.item,
    required this.formatCurrency,
    required this.mapStatusLabel,
    required this.isPaid,
  });

  final Payment item;
  final String Function(double) formatCurrency;
  final String Function(String) mapStatusLabel;
  final bool Function(String) isPaid;

  @override
  Widget build(BuildContext context) {
    final paid = isPaid(item.status);
    final overdue = item.isOverdue;
    final statusLabel = mapStatusLabel(item.status);

    // Use billing_period if available, otherwise parse from due_date
    String periodLabel = item.billingPeriod;
    if (periodLabel.isEmpty) {
      try {
        final date = DateTime.parse(item.dueDate.isNotEmpty ? item.dueDate : item.paymentDate);
        periodLabel = DateFormat('MMMM yyyy', 'id_ID').format(date);
      } catch (_) {
        periodLabel = '-';
      }
    }

    String dateLabel = '';
    if (paid && item.paidAt != null && item.paidAt!.isNotEmpty) {
      try {
        final paidDate = DateTime.parse(item.paidAt!);
        dateLabel = 'Dibayar ${DateFormat('d MMMM yyyy', 'id_ID').format(paidDate)}';
      } catch (_) {
        dateLabel = 'Dibayar';
      }
    } else {
      try {
        final dueDate = DateTime.parse(item.dueDate.isNotEmpty ? item.dueDate : item.paymentDate);
        dateLabel = 'Jatuh tempo ${DateFormat('d MMMM yyyy', 'id_ID').format(dueDate)}';
      } catch (_) {
        dateLabel = '-';
      }
    }

    Color bgColor = paid ? AppTheme.statusMintBg : AppTheme.statusYellowBg;
    Color iconColor = paid ? AppTheme.statusGreenText : AppTheme.statusYellowText;
    IconData iconData = paid ? Icons.check_circle_outline : Icons.access_time;
    Color chipBg = paid ? AppTheme.statusGreenBg : AppTheme.statusYellowBg;
    Color chipText = paid ? AppTheme.statusGreenText : AppTheme.statusYellowText;

    if (overdue) {
      bgColor = const Color(0xFFFDE8E8);
      iconColor = const Color(0xFFB23A48);
      iconData = Icons.warning_amber_rounded;
      chipBg = const Color(0xFFFDE8E8);
      chipText = const Color(0xFFB23A48);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(item.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          RumaStatusChip(
            label: statusLabel,
            backgroundColor: chipBg,
            textColor: chipText,
          ),
        ],
      ),
    );
  }
}
