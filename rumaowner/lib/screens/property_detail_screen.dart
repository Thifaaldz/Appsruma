import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/boarding_house.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/owner_widgets.dart';

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key, this.boardingHouse});

  final BoardingHouse? boardingHouse;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomPriceController = TextEditingController(text: '1500000');
  final List<String> _imageUrls = [];
  bool _isLoading = false;

  bool get _isEdit => widget.boardingHouse != null;

  double _parsePrice(String value, {double fallback = 0}) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return fallback;
    return double.tryParse(normalized) ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    final house = widget.boardingHouse;
    if (house != null) {
      _nameController.text = house.name;
      _addressController.text = house.address;
      _roomPriceController.text = house.defaultRoomPrice.toStringAsFixed(0);
      _imageUrls.addAll(house.imageUrls);
    }
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
        const SnackBar(content: Text('Gagal memilih gambar kosan.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _roomPriceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _roomPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kos, alamat, dan biaya harus diisi.'),
        ),
      );
      return;
    }

    final defaultRoomPrice = _parsePrice(_roomPriceController.text.trim());
    if (defaultRoomPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biaya kamar harus lebih dari 0.')),
      );
      return;
    }

    final payload = BoardingHouse(
      id: widget.boardingHouse?.id ?? 0,
      ownerId: widget.boardingHouse?.ownerId ?? 0,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      imageUrl: _imageUrls.isNotEmpty
          ? _imageUrls.first
          : widget.boardingHouse?.imageUrl ?? '',
      imageUrls: _imageUrls,
      defaultRoomPrice: defaultRoomPrice,
    );

    setState(() => _isLoading = true);
    final provider = context.read<BoardingHouseProvider>();
    final success = _isEdit
        ? await provider.updateBoardingHouse(payload)
        : await provider.addBoardingHouse(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);
    final roomProvider = context.read<RoomProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (success) {
      await roomProvider.fetchRooms();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Kos berhasil diperbarui.' : 'Kos berhasil ditambahkan.',
          ),
        ),
      );
      navigator.pop();
    } else {
      final detail = provider.lastError;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            detail == null || detail.isEmpty
                ? (_isEdit
                      ? 'Gagal memperbarui kos.'
                      : 'Gagal menambahkan kos.')
                : detail,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 12),
              _ImagePickerSection(
                images: _imageUrls,
                onPickImages: _pickImages,
                onRemoveImage: (index) {
                  setState(() => _imageUrls.removeAt(index));
                },
                emptyLabel: 'Tambah Gambar Kosan',
              ),
              if (_imageUrls.isEmpty &&
                  widget.boardingHouse?.imageUrl.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: OwnerImageFrame(
                    imageData: widget.boardingHouse!.imageUrl,
                    width: double.infinity,
                    height: 160,
                    borderRadius: 4,
                  ),
                ),
              ],
              const SizedBox(height: 26),
              _LabeledField(label: 'Nama Kos', controller: _nameController),
              const SizedBox(height: 24),
              _LabeledField(
                label: 'Alamat Kos',
                controller: _addressController,
              ),
              const SizedBox(height: 24),
              _LabeledField(
                label: 'Biaya Kamar / Bulan',
                controller: _roomPriceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.emptyLabel,
  });

  final List<String> images;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Gambar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
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
        const SizedBox(height: 10),
        if (images.isEmpty)
          GestureDetector(
            onTap: onPickImages,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppTheme.darkOlive,
                      size: 34,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emptyLabel,
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
