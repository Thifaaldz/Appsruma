import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/room_provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/owner_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenTenants,
    this.onOpenRooms,
    this.onOpenPayments,
    this.onOpenFinance,
    this.onOpenComplaints,
    this.onOpenExpense,
    this.onOpenKosList,
    this.onOpenVacantRooms,
  });

  final VoidCallback? onOpenTenants;
  final VoidCallback? onOpenRooms;
  final VoidCallback? onOpenPayments;
  final VoidCallback? onOpenFinance;
  final VoidCallback? onOpenComplaints;
  final VoidCallback? onOpenExpense;
  final VoidCallback? onOpenKosList;
  final VoidCallback? onOpenVacantRooms;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AuthProvider>().fetchProfile();
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
      context.read<RoomProvider>().fetchRooms();
      context.read<TenantProvider>().fetchTenants();
      context.read<ComplaintProvider>().fetchComplaints();
      context.read<PaymentProvider>().fetchPayments();
      context.read<ExpenseProvider>().fetchExpenses();
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
    final bhProvider = context.watch<BoardingHouseProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final ownerName = user?.name.isNotEmpty == true ? user!.name : 'Owner';

    final totalKos = bhProvider.boardingHouses.length;
    final rooms = roomProvider.rooms;
    final vacantRooms = rooms.isNotEmpty
        ? rooms.where((room) => room.status.toLowerCase() == 'available').length
        : bhProvider.boardingHouses.fold<int>(
            0,
            (sum, house) =>
                sum + (house.vacantRooms > 0 ? house.vacantRooms : 0),
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
    final expenseLabel = _formatCurrency(expenseProvider.totalExpenses);

    // Count pending payments for reminder
    final pendingPayments = paymentProvider.payments
        .where((p) => p.status == 'pending' || p.status == 'overdue')
        .length;
    final complaintsCount = complaintProvider.complaints
        .where((c) =>
            c.status.toLowerCase() != 'done' &&
            c.status.toLowerCase() != 'selesai')
        .length;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().fetchProfile();
          if (!mounted) return;
          await context.read<BoardingHouseProvider>().fetchBoardingHouses();
          if (!mounted) return;
          await context.read<RoomProvider>().fetchRooms();
          if (!mounted) return;
          await context.read<TenantProvider>().fetchTenants();
          if (!mounted) return;
          await context.read<ComplaintProvider>().fetchComplaints();
          if (!mounted) return;
          await context.read<PaymentProvider>().fetchPayments();
          if (!mounted) return;
          await context.read<ExpenseProvider>().fetchExpenses();
        },
        color: AppTheme.darkOlive,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile header
              OwnerPanel(
                backgroundColor: AppTheme.cardWhite,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    OwnerProfileAvatar(
                      imageData: user?.profileImage ?? '',
                      size: 78,
                      shape: BoxShape.circle,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            ownerName,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.darkOlive,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: AppTheme.lightBeige,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.darkOlive,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: AppTheme.lightBeige,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Dashboard header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkOlive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.dashboard_outlined,
                      color: AppTheme.lightBeige,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.lightBeige,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4 metric cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  // Total Kos - taps to kos list
                  _TappableMetricCard(
                    icon: Icons.home_outlined,
                    title: 'Total Kos',
                    value: '$totalKos Kos',
                    onTap: widget.onOpenKosList,
                  ),
                  // Kamar Kosong - taps to filtered vacant rooms
                  _TappableMetricCard(
                    icon: Icons.meeting_room_outlined,
                    title: 'Kamar Kosong',
                    value: '$vacantRooms Kosong',
                    onTap: widget.onOpenVacantRooms,
                  ),
                  // Pemasukan
                  OwnerMetricCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'Pemasukan Bulan Ini',
                    value: incomeLabel,
                  ),
                  // Pengeluaran - taps to expense form
                  _TappableMetricCard(
                    icon: Icons.trending_down_outlined,
                    title: 'Pengeluaran',
                    value: expenseLabel,
                    onTap: widget.onOpenExpense,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Total Pemasukan card
              OwnerPanel(
                backgroundColor: AppTheme.darkOlive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.bar_chart_outlined,
                      color: AppTheme.lightBeige,
                      size: 34,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Pemasukan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.lightBeige,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      incomeLabel,
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppTheme.lightBeige,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OwnerQuickAction(
                    icon: Icons.payments_outlined,
                    label: 'Pembayaran',
                    onTap: widget.onOpenPayments,
                  ),
                  OwnerQuickAction(
                    icon: Icons.people_outline,
                    label: 'Penghuni',
                    onTap: widget.onOpenTenants,
                  ),
                  OwnerQuickAction(
                    icon: Icons.apartment_outlined,
                    label: 'Kamar Kos',
                    onTap: widget.onOpenRooms,
                  ),
                  OwnerQuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'Laporan\nKeuangan',
                    onTap: widget.onOpenFinance,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reminder panel
              GestureDetector(
                onTap: widget.onOpenPayments,
                child: OwnerPanel(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pengingat Jatuh tempo!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      _CounterBubble(text: '$pendingPayments'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Complaints panel
              GestureDetector(
                onTap: widget.onOpenComplaints,
                child: OwnerPanel(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_chat_unread_outlined, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Keluhan Baru!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      _CounterBubble(text: '$complaintsCount'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _TappableMetricCard extends StatelessWidget {
  const _TappableMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OwnerPanel(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 34, color: AppTheme.darkOlive),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CounterBubble extends StatelessWidget {
  const _CounterBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFCBC7BA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
        ),
      ),
    );
  }
}
