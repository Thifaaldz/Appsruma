import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/complaint_provider.dart';
import '../widgets/owner_widgets.dart';
import 'complaint_detail_screen.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();

    final filteredComplaints = complaintProvider.complaints.where((complaint) {
      final query = _searchQuery.toLowerCase();
      return complaint.title.toLowerCase().contains(query) ||
          complaint.description.toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Keluhan',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            OwnerSearchBar(
              controller: _searchController,
              hintText: 'Cari Keluhan',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 14),
            if (complaintProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredComplaints.isEmpty)
              const Center(child: Text('Tidak ada keluhan ditemukan.'))
            else
              ListView.separated(
                itemCount: filteredComplaints.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final complaint = filteredComplaints[index];
                  final status = complaint.status.toLowerCase();
                  final statusColor = status.contains('done')
                      ? const Color(0xFFD4F0DA)
                      : status.contains('process')
                      ? const Color(0xFFD8E6F7)
                      : const Color(0xFFF0CBD0);
                  final statusTextColor = status.contains('done')
                      ? const Color(0xFF2B5A34)
                      : status.contains('process')
                      ? const Color(0xFF2D4F7E)
                      : const Color(0xFF6E2E39);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ComplaintDetailScreen(complaint: complaint),
                        ),
                      );
                    },
                    child: OwnerPanel(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD9D9D9),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.title,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                Text(
                                  '${complaint.tenantName ?? 'Penyewa'} | ${complaint.roomInfo ?? 'Kos Anggrek A1'}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              OwnerStatusChip(
                                label: complaint.status == 'done'
                                    ? 'Done'
                                    : complaint.status == 'process'
                                    ? 'Sedang di proses'
                                    : 'Belum diproses',
                                backgroundColor: statusColor,
                                textColor: statusTextColor,
                              ),
                              const SizedBox(height: 14),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
