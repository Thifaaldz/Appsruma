import 'package:flutter/material.dart';
import '../core/theme.dart';

class TenantDetailScreen extends StatelessWidget {
  const TenantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rosita Samsulleika Putri', style: Theme.of(context).textTheme.titleLarge),
                      const Text('Kos Anggrek | Kamar A1'),
                      const Text('0812-7653-2261'),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Text('Informasi Penghuni', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow('Nama Lengkap', 'Rosita Samsulleika Putri'),
              _buildInfoRow('Nomor Handphone', '0812-7653-2261'),
              _buildInfoRow('Email', 'rosita@example.com'),
              _buildInfoRow('Jenis Kelamin', 'Perempuan'),
            ]),
            const SizedBox(height: 24),
            Text('Informasi Kamar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow('Nama Kosan', 'Kos Anggrek'),
              _buildInfoRow('Nomor Kamar', 'A1'),
              _buildInfoRow('Harga Kamar', 'Rp. 1.500.000'),
              _buildInfoRow('Status Kamar', 'Terisi', isLink: true),
            ]),
            const SizedBox(height: 24),
            Text('Riwayat Keluhan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow('Daftar Keluhan', '', isLink: true),
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
