import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/tenant_design_data.dart';
import '../widgets/tenant_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onPayNow,
    required this.onOpenHistory,
  });

  final VoidCallback onPayNow;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RumaBrandLogo(height: 22),
            const SizedBox(height: 44),
            Text(
              'Halo, ${TenantDesignData.name}',
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
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'April 2026',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TenantDesignData.monthlyBill,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Jatuh tempo :',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        TenantDesignData.dueDate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RumaStatusChip(
                      label: 'Belum Bayar',
                      backgroundColor: AppTheme.statusYellowBg,
                      textColor: AppTheme.statusYellowText,
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengingat Aktif',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Akan dikirim',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TenantDesignData.dashboardNotices.first.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 12,
                                color: AppTheme.textDark,
                              ),
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
            const RumaSectionHeader(title: 'Notifikasi Terbaru'),
            const SizedBox(height: 10),
            const _HomeNotificationList(),
            const SizedBox(height: 16),
            RumaSectionHeader(
              title: 'Riwayat Terakhir',
              actionLabel: 'Lihat Semua',
              onAction: onOpenHistory,
            ),
            const SizedBox(height: 10),
            const _RecentHistoryCard(),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }
}

class _HomeNotificationList extends StatelessWidget {
  const _HomeNotificationList();

  @override
  Widget build(BuildContext context) {
    return RumaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _HomeNoticeTile(
            iconBackground: const Color(0xFFDDE8FF),
            icon: Icons.notifications_none,
            title: 'Pengingat Pembayaran',
            subtitle: 'Jatuh tempo 3 hari lagi',
          ),
          const Divider(height: 1),
          _HomeNoticeTile(
            iconBackground: const Color(0xFFF9DCDC),
            icon: Icons.campaign_outlined,
            title: 'Pengumuman',
            subtitle: 'Kebersihan lingkungan kos',
          ),
        ],
      ),
    );
  }
}

class _HomeNoticeTile extends StatelessWidget {
  const _HomeNoticeTile({
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color iconBackground;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.textDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDark,
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

class _RecentHistoryCard extends StatelessWidget {
  const _RecentHistoryCard();

  @override
  Widget build(BuildContext context) {
    return RumaPanel(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.statusMintBg,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'April 2026',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            'Rp 1.500.000',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          RumaStatusChip(
            label: 'Lunas',
            backgroundColor: AppTheme.statusGreenBg,
            textColor: AppTheme.statusGreenText,
          ),
        ],
      ),
    );
  }
}
