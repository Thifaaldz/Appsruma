import 'package:flutter/material.dart';
import '../core/theme.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for rooms
    final List<Map<String, dynamic>> rooms = [
      {'name': 'A1', 'property': 'Kos Anggrek', 'period': 'April s/d Oktober', 'price': 'Rp. 1.500.000', 'status': 'Terisi'},
      {'name': 'A2', 'property': 'Kos Anggrek', 'period': 'April s/d Oktober', 'price': 'Rp. 1.500.000', 'status': 'Terisi'},
      {'name': 'A3', 'property': 'Kos Anggrek', 'period': '...', 'price': 'Rp. 1.500.000', 'status': 'Kosong'},
      {'name': 'A4', 'property': 'Kos Anggrek', 'period': 'April s/d Oktober', 'price': 'Rp. 1.500.000', 'status': 'Terisi'},
      {'name': 'A5', 'property': 'Kos Anggrek', 'period': 'April s/d Oktober', 'price': 'Rp. 1.500.000', 'status': 'Terisi'},
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
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kamar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
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
                itemCount: rooms.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final isOccupied = room['status'] == 'Terisi';

                  return Container(
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
                                room['name'],
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                              ),
                              Text(
                                room['property'],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14),
                                  const SizedBox(width: 4),
                                  Text(room['period'], style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOccupied ? AppTheme.statusGreenBg : AppTheme.statusRedBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                room['status'],
                                style: TextStyle(
                                  color: isOccupied ? AppTheme.statusGreenText : AppTheme.statusRedText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              room['price'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
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
