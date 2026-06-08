import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/tenant_design_data.dart';
import '../widgets/tenant_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = TenantDesignData.notifications.where((item) {
      if (_selectedFilter == 'Pengingat') {
        return item.title.toLowerCase().contains('ingat') ||
            item.title.contains('Jatuh Tempo');
      }
      if (_selectedFilter == 'Pengumuman') {
        return item.title == 'Pengumuman';
      }
      if (_selectedFilter == 'Sistem') {
        return item.title == 'Pembayaran Berhasil';
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
            const RumaPageTitle(title: 'Notifikasi'),
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
                  label: 'Pengingat',
                  selected: _selectedFilter == 'Pengingat',
                  onTap: () => setState(() => _selectedFilter = 'Pengingat'),
                ),
                RumaFilterChip(
                  label: 'Pengumuman',
                  selected: _selectedFilter == 'Pengumuman',
                  onTap: () => setState(() => _selectedFilter = 'Pengumuman'),
                ),
                RumaFilterChip(
                  label: 'Sistem',
                  selected: _selectedFilter == 'Sistem',
                  onTap: () => setState(() => _selectedFilter = 'Sistem'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            RumaPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: filteredNotifications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      _NotificationRow(item: item),
                      if (index != filteredNotifications.length - 1)
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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: AppTheme.textDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
