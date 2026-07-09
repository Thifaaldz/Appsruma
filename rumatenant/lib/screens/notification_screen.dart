import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class NotificationItemLocal {
  final IconData icon;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final String time;
  final String type; // 'Pengingat', 'Pengumuman', 'Sistem'

  NotificationItemLocal({
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final announcements = tp.announcements;
    final payments = tp.payments;

    // Create dynamic notification items list
    final List<NotificationItemLocal> allNotifications = [];

    // 1. Map Announcements
    for (final ann in announcements) {
      IconData icon = Icons.campaign_outlined;
      Color bgColor = const Color(0xFFE8F4FD);
      if (ann.icon == 'water') {
        icon = Icons.water_drop_outlined;
        bgColor = const Color(0xFFE3F2FD);
      } else if (ann.icon == 'electric') {
        icon = Icons.flash_on_outlined;
        bgColor = const Color(0xFFFFFDE7);
      } else if (ann.icon == 'repair') {
        icon = Icons.build_outlined;
        bgColor = const Color(0xFFFBE9E7);
      }

      final dateStr = DateFormat('d MMM yyyy, HH.mm', 'id_ID').format(ann.date);

      allNotifications.add(
        NotificationItemLocal(
          icon: icon,
          backgroundColor: bgColor,
          title: ann.title,
          subtitle: ann.content,
          time: dateStr,
          type: 'Pengumuman',
        ),
      );
    }

    // 2. Map Payments into notifications
    for (final p in payments) {
      if (p.status == 'paid') {
        // Successful payment notification
        final dateRaw = p.paidAt ?? p.paymentDate;
        final dateVal = DateTime.tryParse(dateRaw) ?? DateTime.now();
        final dateStr = DateFormat(
          'd MMM yyyy, HH.mm',
          'id_ID',
        ).format(dateVal);

        allNotifications.add(
          NotificationItemLocal(
            icon: Icons.check_circle_outline,
            backgroundColor: const Color(0xFFDDF5E4),
            title: 'Pembayaran Berhasil',
            subtitle: 'Pembayaran tagihan bulan ${p.billingPeriod} lunas.',
            time: dateStr,
            type: 'Sistem',
          ),
        );
      } else if (p.status == 'pending' || p.status == 'overdue') {
        // Billing reminder notification
        final dueDateVal = DateTime.tryParse(p.dueDate) ?? DateTime.now();
        final dateStr = DateFormat('d MMM yyyy', 'id_ID').format(dueDateVal);

        allNotifications.add(
          NotificationItemLocal(
            icon: Icons.notifications_none,
            backgroundColor: p.status == 'overdue'
                ? const Color(0xFFF9DCDC)
                : const Color(0xFFFFF6B9),
            title: p.status == 'overdue'
                ? 'Tagihan Jatuh Tempo!'
                : 'Pengingat Pembayaran',
            subtitle: p.status == 'overdue'
                ? 'Tagihan bulan ${p.billingPeriod} melewati jatuh tempo.'
                : 'Jatuh tempo tanggal $dateStr.',
            time: dateStr,
            type: 'Pengingat',
          ),
        );
      }
    }

    // Sort by time or priority if needed (allNotifications could be sorted, but since we fetched announcements and payments both ordered, we can sort all by parsed date if we want, or just leave as is. Let's sort all by simulated time/order if possible, but actually since we don't have exact parsed date in NotificationItemLocal, let's keep it simple or sort by title/type or let's sort them. Wait, they are already grouped nicely. Let's sort them if needed. Actually order doesn't matter too much, but let's make sure it's clean.)

    final filteredNotifications = allNotifications.where((item) {
      if (_selectedFilter == 'Semua') return true;
      return item.type == _selectedFilter;
    }).toList();
    int countFor(String type) {
      if (type == 'Semua') return allNotifications.length;
      return allNotifications.where((item) => item.type == type).length;
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await tp.refresh();
        },
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
              const RumaPageTitle(title: 'Notifikasi'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.creamSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 8) / 2;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _NotificationFilterButton(
                            label: 'Semua',
                            icon: Icons.notifications_none,
                            count: countFor('Semua'),
                            selected: _selectedFilter == 'Semua',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Semua'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _NotificationFilterButton(
                            label: 'Pengingat',
                            icon: Icons.alarm_outlined,
                            count: countFor('Pengingat'),
                            selected: _selectedFilter == 'Pengingat',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Pengingat'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _NotificationFilterButton(
                            label: 'Pengumuman',
                            icon: Icons.campaign_outlined,
                            count: countFor('Pengumuman'),
                            selected: _selectedFilter == 'Pengumuman',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Pengumuman'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _NotificationFilterButton(
                            label: 'Sistem',
                            icon: Icons.check_circle_outline,
                            count: countFor('Sistem'),
                            selected: _selectedFilter == 'Sistem',
                            onTap: () =>
                                setState(() => _selectedFilter = 'Sistem'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              if (filteredNotifications.isEmpty)
                RumaPanel(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        'Tidak ada notifikasi kategori $_selectedFilter',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                )
              else
                RumaPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: filteredNotifications.asMap().entries.map((
                      entry,
                    ) {
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
      ),
    );
  }
}

class _NotificationFilterButton extends StatelessWidget {
  const _NotificationFilterButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppTheme.textDark;
    final countBackground = selected ? Colors.white : AppTheme.accentSoft;
    final countColor = selected ? AppTheme.olive : AppTheme.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppTheme.olive : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.olive : AppTheme.border,
              width: 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.olive.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: countBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: countColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItemLocal item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
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
        ],
      ),
    );
  }
}
