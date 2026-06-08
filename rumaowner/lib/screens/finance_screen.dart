import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/owner_design_data.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/owner_widgets.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoomProvider>().fetchRooms();
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final bhProvider = context.watch<BoardingHouseProvider>();

    final occupiedRoomList = roomProvider.rooms
        .where((room) => room.status.toLowerCase() == 'occupied')
        .toList();
    final occupiedRooms = occupiedRoomList.length;
    final totalRooms = roomProvider.rooms.isNotEmpty
        ? roomProvider.rooms.length
        : bhProvider.boardingHouses.fold<int>(
            0,
            (sum, house) => sum + (house.totalRooms > 0 ? house.totalRooms : 0),
          );
    final incomeValue = occupiedRoomList.fold<double>(
      0,
      (sum, room) => sum + room.price,
    );
    final incomeLabel = roomProvider.rooms.isNotEmpty
        ? 'Rp. ${incomeValue.toStringAsFixed(0)}'
        : OwnerDesignData.monthlyIncome;
    final expenseLabel = OwnerDesignData.expense;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/RUMA LOGO 1.png',
                height: 30,
                color: AppTheme.accent,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('RUMA');
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Laporan Keuangan',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                OwnerMetricCard(
                  icon: Icons.payments_outlined,
                  title: 'Total Pemasukan',
                  value: incomeLabel,
                ),
                OwnerMetricCard(
                  icon: Icons.trending_down_outlined,
                  title: 'Pengeluaran',
                  value: expenseLabel,
                ),
                OwnerMetricCard(
                  icon: Icons.home_outlined,
                  title: 'Kamar Terisi',
                  value: '$occupiedRooms Kamar',
                ),
                OwnerMetricCard(
                  icon: Icons.meeting_room_outlined,
                  title: 'Total Kamar',
                  value: '$totalRooms Kamar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            OwnerPanel(
              backgroundColor: AppTheme.darkOlive,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Bulan Ini',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightBeige,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$occupiedRooms pembayaran masuk, ${roomProvider.rooms.length - occupiedRooms} kamar belum terisi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightBeige,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const OwnerSectionTitle(title: 'Transaksi Terakhir'),
            const SizedBox(height: 10),
            OwnerPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: OwnerDesignData.financeEntries.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      _FinanceEntryRow(item: item),
                      if (index != OwnerDesignData.financeEntries.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceEntryRow extends StatelessWidget {
  const _FinanceEntryRow({required this.item});

  final OwnerFinanceEntry item;

  @override
  Widget build(BuildContext context) {
    final color = item.isIncome
        ? const Color(0xFFD5F0D8)
        : const Color(0xFFF0CBD0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              size: 20,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.amount,
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
