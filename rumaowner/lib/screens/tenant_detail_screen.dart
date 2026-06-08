import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/boarding_house.dart';
import '../models/room.dart';
import '../models/tenant.dart';
import '../widgets/owner_widgets.dart';

class TenantDetailScreen extends StatelessWidget {
  final Tenant tenant;
  final Room room;
  final BoardingHouse boardingHouse;

  const TenantDetailScreen({
    super.key,
    required this.tenant,
    required this.room,
    required this.boardingHouse,
  });

  @override
  Widget build(BuildContext context) {
    final priceStr = 'Rp ${room.price.toStringAsFixed(0)}';
    final checkIn = _formatDate(tenant.checkInDate);
    final isOccupied = room.status.toLowerCase() == 'occupied';

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      appBar: AppBar(
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Image.asset(
                'assets/RUMA LOGO 1.png',
                height: 32,
                color: AppTheme.accent,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('RUMA');
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.userName ?? 'Rosita Samsulelika Putri',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        '${boardingHouse.name} | Kamar ${room.roomNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        tenant.phone,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontSize: 16),
                      ),
                      Text(
                        'Masuk: $checkIn',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Informasi Penghuni',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            OwnerPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _InfoField(
                    label: 'Nama Lengkap',
                    value: tenant.userName ?? '-',
                  ),
                  _InfoField(label: 'Nomor Handphone', value: tenant.phone),
                  _InfoField(label: 'Email', value: tenant.userEmail ?? '-'),
                  _InfoField(
                    label: 'Jenis Kelamin',
                    value: tenant.gender.isNotEmpty ? tenant.gender : '-',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Informasi Kamar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            OwnerPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _InfoField(label: 'Nama Kosan', value: boardingHouse.name),
                  _InfoField(label: 'Nomor Kamar', value: room.roomNumber),
                  _InfoField(label: 'Harga Kamar', value: priceStr),
                  _ChevronRow(
                    label: 'Status Kamar',
                    value: isOccupied ? 'Terisi' : 'Kosong',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Riwayat Keluhan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            OwnerPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: const _ChevronRow(label: 'Daftar Keluhan', value: ''),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  const _ChevronRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            if (value.isNotEmpty)
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ],
    );
  }
}
