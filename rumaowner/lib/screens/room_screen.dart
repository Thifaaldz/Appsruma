import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../models/room.dart';
import '../models/boarding_house.dart';
import '../core/theme.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<RoomProvider>().fetchRooms();
        context.read<BoardingHouseProvider>().fetchBoardingHouses();
      }
    });
  }

  void _showAddRoomDialog(BuildContext context, List<BoardingHouse> boardingHouses) {
    if (boardingHouses.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kosan Belum Ada'),
          content: const Text('Silakan buat Kosan terlebih dahulu di Tab Beranda.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    final roomNumberController = TextEditingController();
    final priceController = TextEditingController();
    BoardingHouse selectedBH = boardingHouses.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Kamar Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<BoardingHouse>(
                      value: selectedBH,
                      decoration: const InputDecoration(labelText: 'Pilih Kosan'),
                      items: boardingHouses.map((bh) {
                        return DropdownMenuItem(
                          value: bh,
                          child: Text(bh.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedBH = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomNumberController,
                      decoration: const InputDecoration(labelText: 'Nomor Kamar (contoh: A1)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Harga Sewa (Bulanan)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final num = roomNumberController.text.trim();
                    final priceVal = double.tryParse(priceController.text.trim()) ?? 0;

                    if (num.isEmpty || priceVal <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Isi nomor kamar dan harga dengan benar!')),
                      );
                      return;
                    }

                    final room = Room(
                      id: 0,
                      boardingHouseId: selectedBH.id,
                      roomNumber: num,
                      price: priceVal,
                      status: 'available',
                    );

                    final success = await context.read<RoomProvider>().addRoom(room);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Kamar berhasil ditambahkan!' : 'Gagal menambahkan kamar.'),
                        ),
                      );
                      // Refresh homescreen to update room counts
                      context.read<BoardingHouseProvider>().fetchBoardingHouses();
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final bhProvider = context.watch<BoardingHouseProvider>();

    final filteredRooms = roomProvider.rooms.where((room) {
      return room.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
              onPressed: () => _showAddRoomDialog(context, bhProvider.boardingHouses),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kamar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : const Icon(Icons.filter_list, color: Colors.grey),
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
              child: roomProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRooms.isEmpty
                      ? const Center(child: Text('Tidak ada kamar ditemukan.'))
                      : ListView.separated(
                          itemCount: filteredRooms.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final room = filteredRooms[index];
                            final isOccupied = room.status == 'occupied';

                            // Find corresponding boarding house name
                            final bh = bhProvider.boardingHouses.firstWhere(
                              (b) => b.id == room.boardingHouseId,
                              orElse: () => BoardingHouse(id: 0, ownerId: 0, name: 'Kos Anda', address: '', imageUrl: ''),
                            );

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
                                      color: isOccupied ? AppTheme.statusGreenBg : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.meeting_room,
                                      color: isOccupied ? AppTheme.darkOlive : Colors.grey[600],
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kamar ${room.roomNumber}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                                        ),
                                        Text(
                                          bh.name,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.info_outline, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              isOccupied ? 'Aktif' : 'Tersedia',
                                              style: const TextStyle(fontSize: 12),
                                            ),
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
                                          isOccupied ? 'Terisi' : 'Kosong',
                                          style: TextStyle(
                                            color: isOccupied ? AppTheme.statusGreenText : AppTheme.statusRedText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rp ${room.price.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
