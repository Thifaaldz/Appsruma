import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/complaint.dart';
import '../providers/complaint_provider.dart';
import '../widgets/owner_widgets.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  late String _selectedStatus;
  bool _isLoading = false;

  final Map<String, String> _statusMapping = {
    'pending': 'Belum diproses',
    'process': 'Sedang di proses',
    'done': 'Done',
  };

  @override
  void initState() {
    super.initState();
    final currentStatus = widget.complaint.status.toLowerCase();
    _selectedStatus = _statusMapping.containsKey(currentStatus)
        ? currentStatus
        : 'pending';
  }

  Future<void> _saveStatus() async {
    setState(() => _isLoading = true);
    final success = await context
        .read<ComplaintProvider>()
        .updateComplaintStatus(widget.complaint.id, _selectedStatus);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status keluhan berhasil diperbarui!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status keluhan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _selectedStatus == 'done'
        ? const Color(0xFFD4F0DA)
        : _selectedStatus == 'process'
        ? const Color(0xFFD8E6F7)
        : const Color(0xFFF0CBD0);

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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OwnerPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.complaint.title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${widget.complaint.tenantName ?? 'Annisa NF'} | ${widget.complaint.roomInfo ?? 'Kos Anggrek A1'}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ComplaintImage(
                          photoUrl: widget.complaint.photoUrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ComplaintImage(
                          photoUrl: widget.complaint.photoUrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Deskripsi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 96,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.complaint.description.isNotEmpty
                          ? widget.complaint.description
                          : 'Deskripsi keluhan kosong.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Edit Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _statusMapping.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 34),
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveStatus,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.lightBeige,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintImage extends StatelessWidget {
  const _ComplaintImage({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        final commaIndex = photoUrl.indexOf(',');
        if (commaIndex != -1) {
          try {
            final bytes = base64Decode(photoUrl.substring(commaIndex + 1));
            return ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.memory(
                bytes,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          } catch (_) {}
        }
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          photoUrl,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
