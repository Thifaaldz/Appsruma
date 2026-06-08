import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class RoomInfoScreen extends StatelessWidget {
  const RoomInfoScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr.isNotEmpty ? dateStr : '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final room = tp.room;
    final tenant = tp.tenant;
    final boardingHouse = tp.boardingHouse;

    final roomLabel = 'Kamar ${room?.roomNumber ?? '-'}';
    final roomPrice = room?.price ?? boardingHouse?.defaultRoomPrice ?? 0;
    final isActive = room?.status == 'occupied';
    final checkInDate = tenant?.checkInDate ?? '';

    // Room features - these are based on the room data
    // Since the backend doesn't have a room features field yet, we show basic room info
    final features = <_FeatureItem>[
      _FeatureItem(icon: Icons.meeting_room_outlined, label: roomLabel),
      _FeatureItem(icon: Icons.home_outlined, label: boardingHouse?.name ?? '-'),
    ];

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
                  // Room image placeholder
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: room != null && room.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              room.imageUrls.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    size: 40, color: AppTheme.textMuted),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.meeting_room_outlined,
                                size: 40, color: AppTheme.textMuted),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          roomLabel,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      RumaStatusChip(
                        label: isActive ? 'Aktif' : (room?.status ?? '-'),
                        backgroundColor:
                            isActive ? AppTheme.statusMintBg : AppTheme.statusYellowBg,
                        textColor:
                            isActive ? AppTheme.statusMintText : AppTheme.statusYellowText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    boardingHouse?.name ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (boardingHouse?.address.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      boardingHouse!.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  RumaPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Kos',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: features.map((feature) {
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
                                  width: 80,
                                  child: Text(
                                    feature.label,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                      children: [
                        _DetailRow(
                          label: 'Harga Sewa / Bulan',
                          value: _formatCurrency(roomPrice),
                        ),
                        const Divider(height: 1),
                        _DetailRow(
                          label: 'Status Sewa',
                          value: isActive ? 'Aktif' : (room?.status ?? '-'),
                        ),
                        const Divider(height: 1),
                        _DetailRow(
                          label: 'Mulai Sewa',
                          value: _formatDate(checkInDate),
                        ),
                        if (tenant?.checkOutDate.isNotEmpty == true) ...[
                          const Divider(height: 1),
                          _DetailRow(
                            label: 'Selesai Sewa',
                            value: _formatDate(tenant!.checkOutDate),
                          ),
                        ],
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

class _FeatureItem {
  const _FeatureItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
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
