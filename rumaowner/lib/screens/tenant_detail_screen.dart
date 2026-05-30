import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../models/room.dart';
import '../models/boarding_house.dart';
import '../core/theme.dart';

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
    final checkInStr = '${tenant.checkInDate.day}-${tenant.checkInDate.month}-${tenant.checkInDate.year}';
    final priceStr = 'Rp ${room.price.toStringAsFixed(0)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Empty, could have RUMA logo
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Image.asset(
                'assets/RUMA LOGO 1.png',
                height: 32,
                color: AppTheme.darkOlive,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.grey, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tenant.userName ?? 'Nama Penyewa', style: Theme.of(context).textTheme.titleLarge),
                      Text('${boardingHouse.name} | Kamar ${room.roomNumber}'),
                      Text(tenant.phone),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Text('Informasi Penghuni', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow('Nama Lengkap', tenant.userName ?? '-'),
              _buildInfoRow('Nomor Handphone', tenant.phone),
              _buildInfoRow('Email', tenant.userEmail ?? '-'),
              _buildInfoRow('Jenis Kelamin', tenant.gender.isNotEmpty ? tenant.gender : '-'),
              _buildInfoRow('Tanggal Masuk', checkInStr),
            ]),
            const SizedBox(height: 24),
            Text('Informasi Kamar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow('Nama Kosan', boardingHouse.name),
              _buildInfoRow('Nomor Kamar', room.roomNumber),
              _buildInfoRow('Harga Kamar', priceStr),
              _buildInfoRow('Status Kamar', 'Terisi', isLink: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (value.isNotEmpty)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(value),
                )
              else
                const SizedBox(),
              if (isLink)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }
}
