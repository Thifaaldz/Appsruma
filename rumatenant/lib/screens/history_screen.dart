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
    if (s == 'paid' || s == 'lunas') return 'Lunas';
    if (s == 'pending' || s == 'belum bayar') return 'Belum Bayar';
    if (s == 'cancelled') return 'Dibatalkan';
    return status;
  }

  bool _isPaid(String status) {
    final s = status.toLowerCase();
    return s == 'paid' || s == 'lunas';
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final payments = tp.payments;

    final visibleItems = payments.where((item) {
      final label = _mapStatusLabel(item.status);
      if (_selectedFilter == 'Lunas') return label == 'Lunas';
      if (_selectedFilter == 'Belum Bayar') return label == 'Belum Bayar';
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
    final statusLabel = mapStatusLabel(item.status);

    String periodLabel = '';
    String dateLabel = '';
    try {
      final date = DateTime.parse(item.paymentDate);
      periodLabel = DateFormat('MMMM yyyy', 'id_ID').format(date);
      dateLabel = paid
          ? 'Dibayar ${DateFormat('d MMMM yyyy', 'id_ID').format(date)}'
          : 'Jatuh tempo ${DateFormat('d MMMM yyyy', 'id_ID').format(date)}';
    } catch (_) {
      periodLabel = item.paymentDate;
      dateLabel = item.paymentDate;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: paid ? AppTheme.statusMintBg : AppTheme.statusYellowBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              paid ? Icons.check_circle_outline : Icons.access_time,
              size: 18,
              color: paid ? AppTheme.statusGreenText : AppTheme.statusYellowText,
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
            backgroundColor:
                paid ? AppTheme.statusGreenBg : AppTheme.statusYellowBg,
            textColor:
                paid ? AppTheme.statusGreenText : AppTheme.statusYellowText,
          ),
        ],
      ),
    );
  }
}
