import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onOpenComplaint});

  final VoidCallback onOpenComplaint;

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
    final user = tp.user;
    final room = tp.room;
    final tenant = tp.tenant;
    final boardingHouse = tp.boardingHouse;

    final name = user?.name ?? 'Penghuni';
    final roomLabel = 'Penghuni Kamar ${room?.roomNumber ?? '-'}';
    final kosName = boardingHouse?.name ?? 'Kos RUMA';

    // Build fields dynamically based on real data
    final phone = user?.phone.isNotEmpty == true
        ? user!.phone
        : (tenant?.phone.isNotEmpty == true ? tenant!.phone : '-');
    final email = user?.email ?? '-';
    final roomNum = room?.roomNumber ?? '-';
    final checkIn = tenant?.checkInDate ?? '';

    final fields = [
      _ProfileField(
        icon: Icons.phone_outlined,
        label: 'Nomor Telepon',
        value: phone,
      ),
      _ProfileField(icon: Icons.mail_outline, label: 'Email', value: email),
      _ProfileField(
        icon: Icons.meeting_room_outlined,
        label: 'Nomor Kamar',
        value: roomNum,
      ),
      _ProfileField(
        icon: Icons.calendar_month_outlined,
        label: 'Mulai Sewa',
        value: _formatDate(checkIn),
      ),
    ];

    return SafeArea(
      bottom: false,
      child: tp.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.olive),
            )
          : RefreshIndicator(
              onRefresh: () => tp.refresh(),
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
                    const RumaPageTitle(title: 'Profile Saya'),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD9D9D9),
                            ),
                            child: user?.profileImage.isNotEmpty == true
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: Image.network(
                                      user!.profileImage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 48,
                                                color: AppTheme.textSecondary,
                                              ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: AppTheme.textSecondary,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roomLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kosName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    RumaPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: fields.asMap().entries.map((entry) {
                          final index = entry.key;
                          final field = entry.value;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: RumaInfoRow(
                                  icon: field.icon,
                                  label: field.label,
                                  value: field.value,
                                  valueStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              if (index != fields.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: onOpenComplaint,
                      child: RumaPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: AppTheme.textDark,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bantuan dan Keluhan',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.textDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Keluar'),
                              content: const Text(
                                'Apakah Anda yakin ingin keluar?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Keluar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            tp.clear();
                            await context.read<AuthProvider>().logout();
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Keluar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB23A48),
                          foregroundColor: Colors.white,
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

class _ProfileField {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
