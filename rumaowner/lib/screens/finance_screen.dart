import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/payment.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../providers/payment_provider.dart';
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
      context.read<PaymentProvider>().fetchPayments();
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final bhProvider = context.watch<BoardingHouseProvider>();
    final paymentProvider = context.watch<PaymentProvider>();

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

    // Sum of paid payments
    final paidPayments = paymentProvider.payments
        .where((p) => p.status == 'paid')
        .toList();

    final incomeValue = paidPayments.fold<double>(
      0,
      (sum, p) => sum + p.amount,
    );

    final incomeLabel = _formatCurrency(incomeValue);
    // Standard expense fallback
    const expenseLabel = 'Rp 0';

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await roomProvider.fetchRooms();
          await bhProvider.fetchBoardingHouses();
          await paymentProvider.fetchPayments();
        },
        color: AppTheme.darkOlive,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                      '${paidPayments.length} pembayaran masuk lunas, ${roomProvider.rooms.length - occupiedRooms} kamar kosong',
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
              if (paymentProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppTheme.darkOlive),
                  ),
                )
              else if (paymentProvider.payments.isEmpty)
                OwnerPanel(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Belum ada transaksi pembayaran.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                OwnerPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: paymentProvider.payments.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final payment = entry.value;
                      return Column(
                        children: [
                          _FinanceEntryRow(
                            payment: payment,
                            formatCurrency: _formatCurrency,
                          ),
                          if (index != paymentProvider.payments.length - 1)
                            const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceEntryRow extends StatelessWidget {
  const _FinanceEntryRow({
    required this.payment,
    required this.formatCurrency,
  });

  final Payment payment;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status == 'paid';
    final color = isPaid ? const Color(0xFFD5F0D8) : const Color(0xFFF7F4EB);
    final iconColor = isPaid ? const Color(0xFF2B5A34) : AppTheme.textSecondary;
    final dateFormatted = DateFormat('dd MMMM yyyy', 'id_ID').format(payment.paymentDate);

    final tenantName = payment.tenant?.userName ?? 'Penghuni';
    final roomNo = payment.tenant?.roomNumber ?? '';
    final roomLabel = roomNo.isNotEmpty ? ' (Kamar $roomNo)' : '';

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
              isPaid ? Icons.arrow_downward : Icons.access_time,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bayar Kos - $tenantName$roomLabel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateFormatted,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFD5F0D8) : const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPaid ? 'Lunas' : 'Belum Bayar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPaid ? const Color(0xFF2B5A34) : const Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(payment.amount),
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
