import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/room.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/owner_widgets.dart';

class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key, this.room});

  final Room? room;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _imagePicker = ImagePicker();
  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController(text: '1500000');
  final List<String> _imageUrls = [];
  String _selectedStatus = 'available';
  int? _selectedHouseId;
  bool _useDefaultPrice = true;
  bool _isLoading = false;
  bool _hasSyncedSelection = false;

  bool get _isEdit => widget.room != null;

  double _parsePrice(String value, {double fallback = 0}) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return fallback;
    return double.tryParse(normalized) ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    if (room != null) {
      _roomNumberController.text = room.roomNumber;
      _priceController.text = room.price.toStringAsFixed(0);
      _selectedStatus = room.status;
      _selectedHouseId = room.boardingHouseId;
      _useDefaultPrice = room.useDefaultPrice;
      _imageUrls.addAll(room.imageUrls);
    }
    Future.microtask(() {
      if (!mounted) return;
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
      context.read<RoomProvider>().fetchRooms();
    });
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        imageQuality: 82,
      );
      if (images.isEmpty) return;

      final encodedImages = <String>[];
      for (final image in images) {
        final bytes = await image.readAsBytes();
        encodedImages.add('data:image/jpeg;base64,${base64Encode(bytes)}');
      }

      if (!mounted) return;
      setState(() => _imageUrls.addAll(encodedImages));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih gambar kamar.')),
      );
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedHouseId == null ||
        _selectedHouseId! <= 0 ||
        _roomNumberController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kos asli, isi nomor kamar, dan biaya.'),
        ),
      );
      return;
    }

    final price = _parsePrice(_priceController.text.trim());
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biaya kamar harus lebih dari 0.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<RoomProvider>();
    final selectedHouse = context
        .read<BoardingHouseProvider>()
        .boardingHouses
        .where((house) => house.id == _selectedHouseId)
        .toList();
    final defaultPrice = selectedHouse.isNotEmpty
        ? selectedHouse.first.defaultRoomPrice
        : price;
    final payload = Room(
      id: widget.room?.id ?? 0,
      boardingHouseId: _selectedHouseId!,
      roomNumber: _roomNumberController.text.trim(),
      price: _useDefaultPrice ? defaultPrice : price,
      status: _selectedStatus,
      useDefaultPrice: _useDefaultPrice,
      imageUrls: _imageUrls,
    );
    final success = _isEdit
        ? await provider.updateRoom(widget.room!.id, payload)
        : await provider.addRoom(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Kamar berhasil diperbarui.'
                : 'Kamar berhasil ditambahkan.',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Gagal memperbarui kamar.' : 'Gagal menambahkan kamar.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bhProvider = context.watch<BoardingHouseProvider>();
    final boardingHouses = bhProvider.boardingHouses;

    if (boardingHouses.isNotEmpty) {
      final hasValidSelection =
          _selectedHouseId != null &&
          boardingHouses.any((house) => house.id == _selectedHouseId);

      if (!_hasSyncedSelection || !hasValidSelection) {
        final selectedId = hasValidSelection
            ? _selectedHouseId!
            : boardingHouses.first.id;
        final selectedHouse = boardingHouses.firstWhere(
          (house) => house.id == selectedId,
        );
        _hasSyncedSelection = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedHouseId = selectedId;
            if (!_isEdit || _useDefaultPrice) {
              _priceController.text = selectedHouse.defaultRoomPrice
                  .toStringAsFixed(0);
            }
          });
        });
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/RUMA LOGO 1.png',
                  height: 32,
                  color: AppTheme.accent,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('RUMA');
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isEdit ? 'Edit Kamar' : 'Tambah Kamar',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              OwnerSectionTitle(title: 'Pilih Kos'),
              const SizedBox(height: 10),
              if (boardingHouses.isEmpty)
                OwnerPanel(
                  child: Text(
                    bhProvider.isLoading
                        ? 'Memuat data kos...'
                        : 'Belum ada kos. Tambahkan kos dulu sebelum menambah kamar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  key: ValueKey(_selectedHouseId ?? 'boarding-house'),
                  initialValue: _selectedHouseId,
                  items: boardingHouses
                      .map(
                        (house) => DropdownMenuItem(
                          value: house.id,
                          child: Text(house.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    final selectedHouse = boardingHouses.firstWhere(
                      (house) => house.id == value,
                    );
                    setState(() {
                      _selectedHouseId = value;
                      if (!_isEdit || _useDefaultPrice) {
                        _priceController.text = selectedHouse.defaultRoomPrice
                            .toStringAsFixed(0);
                      }
                    });
                  },
                  decoration: const InputDecoration(),
                ),
              const SizedBox(height: 18),
              OwnerPanel(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    _FormField(
                      label: 'Nomor Kamar',
                      controller: _roomNumberController,
                    ),
                    _FormField(
                      label: 'Biaya Kamar / Bulan',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      enabled: !_useDefaultPrice,
                    ),
                    CheckboxListTile(
                      value: _useDefaultPrice,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Ikuti biaya default kos'),
                      onChanged: (value) {
                        final selectedHouse = boardingHouses
                            .where((house) => house.id == _selectedHouseId)
                            .toList();
                        setState(() {
                          _useDefaultPrice = value ?? true;
                          if (_useDefaultPrice && selectedHouse.isNotEmpty) {
                            _priceController.text = selectedHouse
                                .first
                                .defaultRoomPrice
                                .toStringAsFixed(0);
                          }
                        });
                      },
                    ),
                    _StatusDropdown(
                      value: _selectedStatus,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _RoomImagePickerSection(
                      images: _imageUrls,
                      onPickImages: _pickImages,
                      onRemoveImage: (index) {
                        setState(() => _imageUrls.removeAt(index));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _isLoading || boardingHouses.isEmpty
                        ? null
                        : _save,
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
                        : Text(_isEdit ? 'Update' : 'Simpan'),
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;

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
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Kamar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          items: const [
            DropdownMenuItem(value: 'available', child: Text('Kosong')),
            DropdownMenuItem(value: 'occupied', child: Text('Terisi')),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}

class _RoomImagePickerSection extends StatelessWidget {
  const _RoomImagePickerSection({
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  final List<String> images;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Gambar Kamar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onPickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (images.isEmpty)
          GestureDetector(
            onTap: onPickImages,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppTheme.darkOlive,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah Gambar Kamar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          GridView.builder(
            itemCount: images.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  OwnerImageFrame(
                    imageData: images[index],
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 6,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => onRemoveImage(index),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xCCB23A48),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
