import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'complaint_detail_screen.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for complaints
    final List<Map<String, dynamic>> complaints = [
      {'title': 'Toilet Mampet', 'subtitle': 'Annisa NF | Kos Anggrek A1', 'status': 'Belum diproses'},
      {'title': 'Air Suka Mati', 'subtitle': 'Dimas A | Kos Anggrek A1', 'status': 'Done'},
      {'title': 'AC Bocor', 'subtitle': 'Fahra Fazira | Kos Anggrek A1', 'status': 'Sedang di proses'},
    ];

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keluhan', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari Keluhan',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppTheme.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: complaints.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  final status = complaint['status'] as String;
                  
                  Color statusBgColor = AppTheme.statusRedBg;
                  if (status == 'Done') {
                    statusBgColor = AppTheme.statusGreenBg;
                  } else if (status == 'Sedang di proses') {
                    statusBgColor = AppTheme.statusBlueBg;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComplaintDetailScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
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
                                Text(
                                  complaint['title'],
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                                ),
                                Text(
                                  complaint['subtitle'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          status,
                                          style: const TextStyle(
                                            color: AppTheme.textDark,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_right, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
