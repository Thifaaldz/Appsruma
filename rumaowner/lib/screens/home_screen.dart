import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/owner_design_data.dart';
import '../providers/auth_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/room_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/owner_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenTenants,
    this.onOpenRooms,
    this.onOpenFinance,
    this.onOpenComplaints,
  });

  final VoidCallback? onOpenTenants;
  final VoidCallback? onOpenRooms;
  final VoidCallback? onOpenFinance;
  final VoidCallback? onOpenComplaints;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final bhProvider = context.watch<BoardingHouseProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final ownerName = user?.name.isNotEmpty == true ? user!.name : 'Owner';
    final rooms = roomProvider.rooms;
    final totalRooms = rooms.isNotEmpty
        ? rooms.length
        : bhProvider.boardingHouses.fold<int>(
            0,
            (sum, house) => sum + (house.totalRooms > 0 ? house.totalRooms : 0),
          );
    final vacantRooms = rooms.isNotEmpty
        ? rooms.where((room) => room.status.toLowerCase() == 'available').length
        : bhProvider.boardingHouses.fold<int>(
            0,
            (sum, house) =>
                sum + (house.vacantRooms > 0 ? house.vacantRooms : 0),
          );
    final incomeValue = rooms
        .where((room) => room.status.toLowerCase() == 'occupied')
        .fold<double>(0, (sum, room) => sum + room.price);
    final incomeLabel = rooms.isNotEmpty
        ? 'Rp. ${incomeValue.toStringAsFixed(0)}'
        : 'Rp. 0';
    final reminderCount = tenantProvider.tenants.isNotEmpty
        ? tenantProvider.tenants.length
        : 2;
    final complaintsCount = complaintProvider.complaints.isNotEmpty
        ? complaintProvider.complaints.length
        : 4;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OwnerPanel(
              backgroundColor: AppTheme.cardWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          ownerName,
                          style: Theme.of(context).textTheme.displayLarge
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                OwnerMetricCard(
                  icon: Icons.home_outlined,
                  title: 'Total Kamar',
                  value: totalRooms > 0 ? '$totalRooms Kamar' : '10 Kamar',
                ),
                OwnerMetricCard(
                  icon: Icons.meeting_room_outlined,
                  title: 'Kosong',
                  value: vacantRooms > 0 ? '$vacantRooms Kosong' : '5 Kosong',
                ),
                OwnerMetricCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'Pemasukan Bulan Ini',
                  value: incomeLabel,
                ),
                OwnerMetricCard(
                  icon: Icons.trending_down_outlined,
                  title: 'Pengeluaran',
                  value: OwnerDesignData.expense,
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.lightBeige,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: OwnerDesignData.actions.map((action) {
                return OwnerQuickAction(
                  icon: action.icon,
                  label: action.label,
                  onTap: () {
                    if (action.label.startsWith('Penghuni')) {
                      widget.onOpenTenants?.call();
                    } else if (action.label.startsWith('Kamar')) {
                      widget.onOpenRooms?.call();
                    } else if (action.label.startsWith('Laporan')) {
                      widget.onOpenFinance?.call();
                    } else {
                      widget.onOpenComplaints?.call();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            OwnerPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pengingat Jatuh tempo!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _CounterBubble(text: '$reminderCount'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OwnerPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.mark_chat_unread_outlined, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Keluhan Baru!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _CounterBubble(text: '$complaintsCount'),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
