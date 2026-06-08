import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/tenant_design_data.dart';
import '../widgets/tenant_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final visibleItems = TenantDesignData.paymentHistory.where((item) {
      if (_selectedFilter == 'Lunas') {
        return item.status == 'Lunas';
      }
      if (_selectedFilter == 'Belum Bayar') {
        return item.status == 'Belum Bayar';
      }
      return true;
    }).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
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
                  onTap: () => setState(() => _selectedFilter = 'Belum Bayar'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            RumaPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: visibleItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      _HistoryItemRow(item: item),
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
  const _HistoryItemRow({required this.item});

  final PaymentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == 'Belum Bayar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPending
                  ? AppTheme.statusYellowBg
                  : AppTheme.statusMintBg,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.period,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          RumaStatusChip(
            label: item.status,
            backgroundColor: item.statusColor,
            textColor: item.statusTextColor,
          ),
          const SizedBox(width: 8),
          Icon(item.trailingIcon, size: 22, color: AppTheme.textDark),
        ],
      ),
    );
  }
}
