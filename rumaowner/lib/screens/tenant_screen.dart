import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/room_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../models/tenant.dart';
import '../models/room.dart';
import '../models/boarding_house.dart';
import '../core/theme.dart';
import 'tenant_detail_screen.dart';

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
      if (mounted) {
        context.read<TenantProvider>().fetchTenants();
        context.read<TenantProvider>().fetchTenantUsers();
        context.read<RoomProvider>().fetchRooms();
        context.read<BoardingHouseProvider>().fetchBoardingHouses();
      }
    });
  }

  void _showAddTenantDialog(
      BuildContext context, List<Map<String, dynamic>> tenantUsers, List<Room> rooms) {
    // Only show available/unoccupied rooms
    final availableRooms = rooms.where((r) => r.status == 'available').toList();

    if (availableRooms.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kamar Penuh'),
          content: const Text('Tidak ada kamar kosong yang tersedia. Silakan tambah kamar baru terlebih dahulu.'),
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

    bool isNewAccount = tenantUsers.isEmpty;
    Map<String, dynamic>? selectedUser = tenantUsers.isNotEmpty ? tenantUsers.first : null;
    Room selectedRoom = availableRooms.first;
    
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String gender = 'Laki-laki';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Penghuni Kamar'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tenantUsers.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Pilih Akun')),
                              selected: !isNewAccount,
                              onSelected: (val) {
                                setDialogState(() {
                                  isNewAccount = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Akun Baru')),
                              selected: isNewAccount,
                              onSelected: (val) {
                                setDialogState(() {
                                  isNewAccount = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!isNewAccount && tenantUsers.isNotEmpty) ...[
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: selectedUser,
                        decoration: const InputDecoration(labelText: 'Pilih Akun Penyewa'),
                        items: tenantUsers.map((user) {
                          return DropdownMenuItem(
                            value: user,
                            child: Text(user['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedUser = val;
                            });
                          }
                        },
                      ),
                    ] else ...[
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email Akun'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'Password Akun'),
                        obscureText: true,
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Room>(
                      value: selectedRoom,
                      decoration: const InputDecoration(labelText: 'Pilih Kamar Kosong'),
                      items: availableRooms.map((room) {
                        return DropdownMenuItem(
                          value: room,
                          child: Text('Kamar ${room.roomNumber}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRoom = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Nomor Handphone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                      items: const [
                        DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            gender = val;
                          });
                        }
                      },
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
                    final phone = phoneController.text.trim();
                    if (phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nomor handphone harus diisi!')),
                      );
                      return;
                    }

                    if (isNewAccount) {
                      final name = nameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (name.isEmpty || email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lengkapi nama, email, dan password untuk membuat akun baru!')),
                        );
                        return;
                      }

                      final newTenant = Tenant(
                        id: 0,
                        userId: 0, // 0 triggers new user creation
                        roomId: selectedRoom.id,
                        phone: phone,
                        gender: gender,
                        checkInDate: DateTime.now(),
                        name: name,
                        email: email,
                        password: password,
                      );

                      final success = await context.read<TenantProvider>().addTenant(newTenant);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Penghuni & akun baru berhasil ditambahkan!' : 'Gagal menambahkan penghuni/akun.'),
                          ),
                        );
                        // Refresh details
                        context.read<RoomProvider>().fetchRooms();
                        context.read<TenantProvider>().fetchTenantUsers();
                      }
                    } else {
                      if (selectedUser == null) return;
                      final newTenant = Tenant(
                        id: 0,
                        userId: selectedUser!['id'] ?? 0,
                        roomId: selectedRoom.id,
                        phone: phone,
                        gender: gender,
                        checkInDate: DateTime.now(),
                      );

                      final success = await context.read<TenantProvider>().addTenant(newTenant);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Penghuni berhasil ditambahkan!' : 'Gagal menambahkan penghuni.'),
                          ),
                        );
                        context.read<RoomProvider>().fetchRooms();
                      }
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
    final tenantProvider = context.watch<TenantProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final bhProvider = context.watch<BoardingHouseProvider>();

    final filteredTenants = tenantProvider.tenants.where((t) {
      final name = t.userName ?? '';
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
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
              onPressed: () => _showAddTenantDialog(
                context,
                tenantProvider.tenantUsers,
                roomProvider.rooms,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Penghuni'),
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
                    : null,
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
              child: tenantProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTenants.isEmpty
                      ? const Center(child: Text('Tidak ada penghuni ditemukan.'))
                      : ListView.separated(
                          itemCount: filteredTenants.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tenant = filteredTenants[index];

                            // Try to find the associated room
                            final room = roomProvider.rooms.firstWhere(
                              (r) => r.id == tenant.roomId,
                              orElse: () => Room(id: 0, boardingHouseId: 0, roomNumber: tenant.roomNumber ?? '?', price: 0, status: ''),
                            );

                            // Try to find the associated boarding house
                            final bh = bhProvider.boardingHouses.firstWhere(
                              (b) => b.id == room.boardingHouseId,
                              orElse: () => BoardingHouse(id: 0, ownerId: 0, name: 'Kos Anda', address: '', imageUrl: ''),
                            );

                            final checkInStr = '${tenant.checkInDate.day}-${tenant.checkInDate.month}-${tenant.checkInDate.year}';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TenantDetailScreen(tenant: tenant, room: room, boardingHouse: bh),
                                  ),
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
                                      child: const Icon(Icons.person, color: Colors.grey, size: 30),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tenant.userName ?? 'Nama Penyewa',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Text(
                                            '${bh.name} | Kamar ${room.roomNumber}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 14),
                                              const SizedBox(width: 4),
                                              Text(checkInStr, style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(tenant.phone, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.statusBlueBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.phone),
                                            onPressed: () {},
                                            color: AppTheme.darkOlive,
                                            iconSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
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
