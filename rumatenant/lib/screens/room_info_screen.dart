import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/tenant_design_data.dart';
import '../widgets/tenant_widgets.dart';

class RoomInfoScreen extends StatelessWidget {
  const RoomInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RumaBrandLogo(height: 22),
                  const SizedBox(height: 34),
                  const RumaPageTitle(title: 'Detail Kamar'),
                  const SizedBox(height: 24),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          TenantDesignData.roomLabel,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      RumaStatusChip(
                        label: 'Aktif',
                        backgroundColor: AppTheme.statusMintBg,
                        textColor: AppTheme.statusMintText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TenantDesignData.floorAndSize,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RumaPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fasilitas',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: TenantDesignData.roomFeatures.map((
                            feature,
                          ) {
                            return Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusMintBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    feature.icon,
                                    size: 28,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    feature.label,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  RumaPanel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: const [
                        _DetailRow(
                          label: 'Harga Sewa / Bulan',
                          value: 'Rp 1.500.000',
                        ),
                        Divider(height: 1),
                        _DetailRow(label: 'Status Sewa', value: 'Aktif'),
                        Divider(height: 1),
                        _DetailRow(
                          label: 'Mulai Sewa',
                          value: '4 September 2025',
                        ),
                        Divider(height: 1),
                        _DetailRow(
                          label: 'Jatuh Tempo',
                          value: '10 Setiap Bulan',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  RumaPanel(
                    backgroundColor: const Color(0xFFF1E3C7),
                    borderColor: const Color(0xFFF1E3C7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aturan Kos',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jaga kebersihan kos, tidak membuat keributan,\npatuhi jam malam (22.00)',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          RumaBottomNav(currentIndex: 0, onTap: (_) {}),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
