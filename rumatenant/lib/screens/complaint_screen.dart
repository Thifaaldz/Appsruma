import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/tenant_design_data.dart';
import '../models/complaint.dart';
import '../providers/complaint_provider.dart';
import '../widgets/tenant_widgets.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _descriptionController = TextEditingController();
  String _activeTab = 'Buat Laporan';
  String _selectedCategory = 'AC';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ComplaintProvider>().fetchComplaints();
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();
    final complaintItems = complaintProvider.complaints.isNotEmpty
        ? complaintProvider.complaints
              .map(
                (complaint) => ComplaintHistoryItem(
                  title: complaint.title,
                  subtitle: complaint.description,
                  status: _mapStatus(complaint.status),
                  statusColor: _statusBackground(complaint.status),
                  statusTextColor: _statusTextColor(complaint.status),
                  date: 'Hari ini',
                ),
              )
              .toList()
        : TenantDesignData.complaintHistory;

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RumaBrandLogo(height: 22),
              const SizedBox(height: 34),
              const RumaPageTitle(title: 'Bantuan dan Keluhan'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _TopTabButton(
                      label: 'Buat Laporan',
                      selected: _activeTab == 'Buat Laporan',
                      onTap: () => setState(() => _activeTab = 'Buat Laporan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TopTabButton(
                      label: 'Riwayat Laporan',
                      selected: _activeTab == 'Riwayat Laporan',
                      onTap: () =>
                          setState(() => _activeTab = 'Riwayat Laporan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_activeTab == 'Buat Laporan') ...[
                Text(
                  'Kategori',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: const [
                        DropdownMenuItem(value: 'AC', child: Text('AC')),
                        DropdownMenuItem(value: 'Lampu', child: Text('Lampu')),
                        DropdownMenuItem(value: 'Air', child: Text('Air')),
                        DropdownMenuItem(
                          value: 'Keamanan',
                          child: Text('Keamanan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Deskripsi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 116,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                RumaPanel(
                  backgroundColor: const Color(0xFFF8F0E0),
                  borderColor: const Color(0xFFE7DABF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  'Tambah Foto',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppTheme.olive,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                RumaPrimaryButton(
                  label: 'Kirim Laporan',
                  onPressed: () async {
                    final description = _descriptionController.text.trim();
                    if (description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Deskripsi harus diisi.')),
                      );
                      return;
                    }

                    final success = await context
                        .read<ComplaintProvider>()
                        .addComplaint(
                          Complaint(
                            id: 0,
                            tenantId: 0,
                            title: _selectedCategory,
                            description: description,
                            status: 'pending',
                          ),
                        );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Laporan berhasil dikirim.'
                                : 'Laporan gagal dikirim.',
                          ),
                        ),
                      );
                      if (success) {
                        _descriptionController.clear();
                        setState(() => _activeTab = 'Riwayat Laporan');
                      }
                    }
                  },
                ),
                const SizedBox(height: 18),
                const RumaSectionHeader(title: 'Butuh bantuan cepat?'),
                const SizedBox(height: 8),
                RumaPanel(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.textDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chat Admin',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hubungi pengelola kos langsung',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textDark,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                RumaPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: complaintItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Column(
                        children: [
                          _ComplaintHistoryRow(item: item),
                          if (index != complaintItems.length - 1)
                            const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: RumaBottomNav(
        currentIndex: 0,
        onTap: (_) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  String _mapStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('done') || normalized.contains('selesai')) {
      return 'Selesai';
    }
    if (normalized.contains('process') || normalized.contains('proses')) {
      return 'Diproses';
    }
    return 'Menunggu';
  }

  Color _statusBackground(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('done') || normalized.contains('selesai')) {
      return AppTheme.statusGreenBg;
    }
    if (normalized.contains('process') || normalized.contains('proses')) {
      return AppTheme.statusBlueBg;
    }
    return AppTheme.statusYellowBg;
  }

  Color _statusTextColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('done') || normalized.contains('selesai')) {
      return AppTheme.statusGreenText;
    }
    if (normalized.contains('process') || normalized.contains('proses')) {
      return AppTheme.statusBlueText;
    }
    return AppTheme.statusYellowText;
  }
}

class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.olive : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppTheme.olive : const Color(0xFFD9D9D9),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _ComplaintHistoryRow extends StatelessWidget {
  const _ComplaintHistoryRow({required this.item});

  final ComplaintHistoryItem item;

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
              color: item.statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
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
                  item.date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          RumaStatusChip(
            label: item.status,
            backgroundColor: item.statusColor,
            textColor: item.statusTextColor,
          ),
        ],
      ),
    );
  }
}
