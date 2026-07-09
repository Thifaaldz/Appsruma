import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/boarding_house.dart';
import '../models/room.dart';
import '../models/tenant.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/owner_widgets.dart';

class TenantFormScreen extends StatefulWidget {
  const TenantFormScreen({super.key});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'Laki-laki';
  int? _selectedHouseId;
  int? _selectedRoomId;
  bool _isLoading = false;
  bool _hasSyncedSelection = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final bhId = context
          .read<BoardingHouseProvider>()
          .selectedBoardingHouse
          ?.id;
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
      context.read<RoomProvider>().fetchRooms(boardingHouseId: bhId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save(Room selectedRoom) async {
    if (_selectedHouseId == null ||
        _selectedRoomId == null ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data penghuni, akun, kos, dan kamar.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final bhId = context
        .read<BoardingHouseProvider>()
        .selectedBoardingHouse
        ?.id;
    final success = await context.read<TenantProvider>().addTenant(
      Tenant(
        id: 0,
        userId: 0,
        roomId: selectedRoom.id,
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        checkInDate: DateTime.now(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );

    if (success && mounted) {
      await context.read<RoomProvider>().fetchRooms(boardingHouseId: bhId);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penghuni dan akun tenant berhasil dibuat.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan penghuni.')),
      );
    }
  }

  List<Room> _availableRoomsForHouse(List<Room> rooms) {
    if (_selectedHouseId == null) return [];
    return rooms
        .where(
          (room) =>
              room.boardingHouseId == _selectedHouseId &&
              room.status.toLowerCase() == 'available',
        )
        .toList()
      ..sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
  }

  String _formatCurrency(double value) {
    final text = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final bhProvider = context.watch<BoardingHouseProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final selectedBh = bhProvider.selectedBoardingHouse;
    final boardingHouses = selectedBh == null
        ? bhProvider.boardingHouses
        : bhProvider.boardingHouses
              .where((house) => house.id == selectedBh.id)
              .toList();

    if (boardingHouses.isNotEmpty && !_hasSyncedSelection) {
      _hasSyncedSelection = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(
          () => _selectedHouseId = selectedBh?.id ?? boardingHouses.first.id,
        );
      });
    }

    final roomsForHouse = _availableRoomsForHouse(roomProvider.rooms);
    final hasValidRoom =
        _selectedRoomId != null &&
        roomsForHouse.any((room) => room.id == _selectedRoomId);
    if (roomsForHouse.isNotEmpty && !hasValidRoom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedRoomId = roomsForHouse.first.id);
      });
    } else if (roomsForHouse.isEmpty && _selectedRoomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedRoomId = null);
      });
    }

    BoardingHouse? selectedHouse;
    for (final house in boardingHouses) {
      if (house.id == _selectedHouseId) {
        selectedHouse = house;
        break;
      }
    }

    Room? selectedRoom;
    for (final room in roomsForHouse) {
      if (room.id == _selectedRoomId) {
        selectedRoom = room;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'isi data penghuni',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              OwnerSectionTitle(title: 'Pilih Unit'),
              const SizedBox(height: 10),
              OwnerPanel(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    if (boardingHouses.isEmpty)
                      _EmptyText(
                        text: bhProvider.isLoading
                            ? 'Memuat data kos...'
                            : 'Belum ada kos. Tambahkan kos dulu.',
                      )
                    else
                      _DropdownField<int>(
                        label: 'Nama Kos',
                        value: _selectedHouseId,
                        items: boardingHouses
                            .map(
                              (house) => DropdownMenuItem(
                                value: house.id,
                                child: Text(house.name),
                              ),
                            )
                            .toList(),
                        onChanged: selectedBh != null
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedHouseId = value;
                                  _selectedRoomId = null;
                                });
                              },
                      ),
                    if (roomsForHouse.isEmpty)
                      _EmptyText(
                        text: _selectedHouseId == null
                            ? 'Pilih kos dulu.'
                            : 'Tidak ada kamar kosong di kos ini.',
                      )
                    else
                      _DropdownField<int>(
                        label: 'Nomor Kamar',
                        value: _selectedRoomId,
                        items: roomsForHouse
                            .map(
                              (room) => DropdownMenuItem(
                                value: room.id,
                                child: Text(
                                  'Kamar ${room.roomNumber} - ${_formatCurrency(room.price)}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRoomId = value),
                      ),
                    _PaymentPreview(
                      house: selectedHouse,
                      room: selectedRoom,
                      formatCurrency: _formatCurrency,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OwnerSectionTitle(title: 'Informasi Penghuni'),
              const SizedBox(height: 10),
              OwnerPanel(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    _FormField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                    ),
                    _FormField(
                      label: 'Nomor Handphone',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _DropdownField<String>(
                      label: 'Jenis Kelamin',
                      value: _selectedGender,
                      items: const [
                        DropdownMenuItem(
                          value: 'Laki-laki',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem(
                          value: 'Perempuan',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedGender = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OwnerSectionTitle(title: 'Akun Tenant'),
              const SizedBox(height: 10),
              OwnerPanel(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    _FormField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _FormField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _isLoading || selectedRoom == null
                        ? null
                        : () => _save(selectedRoom!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.olive,
                      foregroundColor: AppTheme.lightBeige,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.lightBeige,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentPreview extends StatelessWidget {
  const _PaymentPreview({
    required this.house,
    required this.room,
    required this.formatCurrency,
  });

  final BoardingHouse? house;
  final Room? room;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.navButton,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total yang harus dibayar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            room == null
                ? 'Pilih kamar dulu'
                : '${formatCurrency(room!.price)} / bulan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            room == null
                ? '-'
                : '${house?.name ?? 'Kos'} - Kamar ${room!.roomNumber}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
