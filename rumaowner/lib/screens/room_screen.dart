import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/boarding_house.dart';
import '../models/room.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/owner_widgets.dart';
import 'property_detail_screen.dart';
import 'room_form_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, this.filterVacant = false});

  final bool filterVacant;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final bhId = context.read<BoardingHouseProvider>().selectedBoardingHouse?.id;
      context.read<RoomProvider>().fetchRooms(boardingHouseId: bhId);
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
    });
  }

  void _openAddBoardingHouse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PropertyDetailScreen()),
    );
  }

  void _openEditBoardingHouse(BoardingHouse house) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(boardingHouse: house),
      ),
    );
  }

  void _openAddRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoomFormScreen()),
    );
  }

  void _openEditRoom(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomFormScreen(room: room)),
    );
  }

  Future<void> _confirmDeleteBoardingHouse(BoardingHouse house) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kosan?'),
          content: Text(
            'Kos "${house.name}" akan dihapus dari daftar. Pastikan data ini memang sudah tidak dipakai.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await context
        .read<BoardingHouseProvider>()
        .deleteBoardingHouse(house.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Kosan berhasil dihapus.' : 'Gagal menghapus kosan.',
        ),
      ),
    );
  }

  String _houseNameForRoom(int boardingHouseId, List<BoardingHouse> houses) {
    final house = houses.where((item) => item.id == boardingHouseId).toList();
    if (house.isNotEmpty) return house.first.name;
    return 'Kosan #$boardingHouseId';
  }

  @override
  Widget build(BuildContext context) {
    final bhProvider = context.watch<BoardingHouseProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final selectedBh = bhProvider.selectedBoardingHouse;

    final boardingHouses = selectedBh != null
        ? bhProvider.boardingHouses.where((h) => h.id == selectedBh.id).toList()
        : bhProvider.boardingHouses;

    var allRooms = List<Room>.from(roomProvider.rooms);
    if (widget.filterVacant) {
      allRooms = allRooms
          .where((r) => r.status.toLowerCase() == 'available')
          .toList();
    }
    final rooms = allRooms
      ..sort((a, b) {
        final houseCompare = a.boardingHouseId.compareTo(b.boardingHouseId);
        if (houseCompare != 0) return houseCompare;
        return a.roomNumber.compareTo(b.roomNumber);
      });

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Kembali',
                ),
                Expanded(
                  child: Text(
                    widget.filterVacant ? 'Kamar Kosong' : 'Daftar Kos & Kamar',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openAddBoardingHouse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkOlive,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+ Tambah Kosan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightBeige,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openAddRoom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        '+ Tambah Kamar',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (boardingHouses.isEmpty)
              OwnerPanel(
                child: Text(
                  bhProvider.isLoading
                      ? 'Memuat data kos...'
                      : bhProvider.lastError?.isNotEmpty == true
                      ? 'Gagal memuat data kos: ${bhProvider.lastError}'
                      : 'Belum ada kos. Gunakan tombol + Tambah Kosan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: boardingHouses.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  if (index == boardingHouses.length) {
                    return GestureDetector(
                      onTap: _openAddBoardingHouse,
                      child: OwnerPanel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppTheme.olive,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppTheme.lightBeige,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Tambah Kosan',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final house = boardingHouses[index];
                  final houseImages = house.imageUrls.isNotEmpty
                      ? house.imageUrls
                      : [
                          house.imageUrl.isNotEmpty
                              ? house.imageUrl
                              : 'https://picsum.photos/seed/${house.name}/500/360',
                        ];
                  final roomsForHouse = roomProvider.rooms
                      .where((room) => room.boardingHouseId == house.id)
                      .toList();
                  final totalRooms = house.totalRooms > 0
                      ? house.totalRooms
                      : roomsForHouse.length;
                  final vacantRooms = house.vacantRooms > 0
                      ? house.vacantRooms
                      : roomsForHouse
                            .where(
                              (room) =>
                                  room.status.toLowerCase() == 'available',
                            )
                            .length;

                  return GestureDetector(
                    onTap: () => _openEditBoardingHouse(house),
                    child: OwnerPanel(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: OwnerImageSlideshow(
                                    images: houseImages,
                                    width: double.infinity,
                                    height: double.infinity,
                                    borderRadius: 10,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Row(
                                    children: [
                                      _CardIconButton(
                                        icon: Icons.edit,
                                        backgroundColor: AppTheme.navButton,
                                        iconColor: AppTheme.darkOlive,
                                        onTap: () =>
                                            _openEditBoardingHouse(house),
                                      ),
                                      const SizedBox(width: 6),
                                      _CardIconButton(
                                        icon: Icons.delete_outline,
                                        backgroundColor: const Color(
                                          0xFFF8D7DA,
                                        ),
                                        iconColor: const Color(0xFFB23A48),
                                        onTap: () =>
                                            _confirmDeleteBoardingHouse(house),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            house.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _CountBadge(
                                text: '$totalRooms Kamar',
                                backgroundColor: const Color(0xFFF1DDB6),
                                textColor: const Color(0xFF534A2A),
                              ),
                              _CountBadge(
                                text: '$vacantRooms Kosong',
                                backgroundColor: const Color(0xFFB93C3C),
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Default biaya: Rp ${house.defaultRoomPrice.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            OwnerSectionTitle(title: 'Daftar Kamar'),
            const SizedBox(height: 10),
            if (rooms.isEmpty)
              OwnerPanel(
                child: Text(
                  'Belum ada kamar yang ditambahkan. Gunakan tombol + Tambah Kamar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rooms.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final houseName = _houseNameForRoom(
                    room.boardingHouseId,
                    boardingHouses,
                  );
                  final house = boardingHouses
                      .where((item) => item.id == room.boardingHouseId)
                      .toList();
                  final List<String> houseImages = house.isNotEmpty
                      ? (house.first.imageUrls.isNotEmpty
                            ? house.first.imageUrls
                            : house.first.imageUrl.isNotEmpty
                            ? [house.first.imageUrl]
                            : <String>[])
                      : <String>[];
                  final isOccupied = room.status.toLowerCase() == 'occupied';

                  return OwnerPanel(
                    child: Row(
                      children: [
                        if (houseImages.isNotEmpty)
                          OwnerImageSlideshow(
                            images: houseImages,
                            width: 66,
                            height: 66,
                            borderRadius: 14,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: isOccupied
                                  ? const Color(0xFFB93C3C)
                                  : AppTheme.olive,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                room.roomNumber,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kamar ${room.roomNumber}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                houseName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  OwnerStatusChip(
                                    label: isOccupied ? 'Terisi' : 'Kosong',
                                    backgroundColor: isOccupied
                                        ? const Color(0xFFF8D7DA)
                                        : const Color(0xFFE4F1E8),
                                    textColor: isOccupied
                                        ? const Color(0xFFB23A48)
                                        : const Color(0xFF2F6B40),
                                  ),
                                  Text(
                                    'Rp ${room.price.toStringAsFixed(0)} / bulan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => _openEditRoom(room),
                          icon: const Icon(Icons.edit, color: AppTheme.olive),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardIconButton extends StatelessWidget {
  const _CardIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}
