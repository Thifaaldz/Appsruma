import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/owner_design_data.dart';
import '../models/boarding_house.dart';
import '../models/room.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/owner_widgets.dart';
import 'tenant_detail_screen.dart';
import 'tenant_form_screen.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final bhId = context
          .read<BoardingHouseProvider>()
          .selectedBoardingHouse
          ?.id;
      context.read<TenantProvider>().fetchTenants(boardingHouseId: bhId);
      context.read<TenantProvider>().fetchTenantUsers(boardingHouseId: bhId);
      context.read<RoomProvider>().fetchRooms(boardingHouseId: bhId);
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TenantFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final bhProvider = context.watch<BoardingHouseProvider>();
    final selectedBh = bhProvider.selectedBoardingHouse;

    final filteredTenants = tenantProvider.tenants.where((tenant) {
      final query = _searchQuery.toLowerCase();
      if (selectedBh != null && tenant.boardingHouseId != selectedBh.id) {
        return false;
      }
      return (tenant.userName ?? '').toLowerCase().contains(query) ||
          tenant.phone.toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkOlive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: GestureDetector(
                  onTap: _openForm,
                  child: Text(
                    '+ Tambah Penghuni',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightBeige,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            OwnerSearchBar(
              controller: _searchController,
              hintText: 'Search',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 14),
            if (tenantProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredTenants.isEmpty)
              const Center(child: Text('Tidak ada penghuni ditemukan.'))
            else
              ListView.separated(
                itemCount: filteredTenants.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tenant = filteredTenants[index];
                  final room = roomProvider.rooms.firstWhere(
                    (item) => item.id == tenant.roomId,
                    orElse: () => Room(
                      id: 0,
                      boardingHouseId: 0,
                      roomNumber: 'A1',
                      price: 1500000,
                      status: 'available',
                    ),
                  );
                  final bh = bhProvider.boardingHouses.firstWhere(
                    (item) => item.id == room.boardingHouseId,
                    orElse: () => BoardingHouse(
                      id: 0,
                      ownerId: 0,
                      name: OwnerDesignData.houseName,
                      address: '',
                      imageUrl: '',
                    ),
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TenantDetailScreen(
                            tenant: tenant,
                            room: room,
                            boardingHouse: bh,
                          ),
                        ),
                      );
                    },
                    child: OwnerPanel(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
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
                                  tenant.userName ?? 'Rosita Samsulelika Putri',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Text(
                                  '${bh.name} | Kamar ${room.roomNumber}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(tenant.checkInDate),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tenant.phone,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBE7F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.phone, size: 20),
                              ),
                              const SizedBox(height: 22),
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

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
