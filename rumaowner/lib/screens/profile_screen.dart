import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/room_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/owner_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_fade);

    Future.microtask(() {
      if (!mounted) return;
      context.read<AuthProvider>().fetchProfile();
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
      context.read<RoomProvider>().fetchRooms();
      context.read<TenantProvider>().fetchTenants();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun owner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB23A48),
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  Future<void> _openEditProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) {
      await auth.fetchProfile();
    }
    if (!mounted) return;
    final user = auth.currentUser;
    if (user == null) {
      final error = auth.profileError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Data user login belum terbaca.')),
      );
      return;
    }
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EditProfileSheet(user: user, auth: auth);
      },
    );

    if (!mounted || success == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile owner berhasil diperbarui.'
              : 'Profile tidak diubah.',
        ),
      ),
    );
  }

  String _money(double value) {
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
    final houses = context.watch<BoardingHouseProvider>().boardingHouses;
    final rooms = context.watch<RoomProvider>().rooms;
    final tenants = context.watch<TenantProvider>().tenants;
    final user = context.watch<AuthProvider>().currentUser;
    final occupiedRooms = rooms
        .where((room) => room.status.toLowerCase() == 'occupied')
        .toList();
    final availableRooms = rooms
        .where((room) => room.status.toLowerCase() == 'available')
        .length;
    final monthlyRevenue = occupiedRooms.fold<double>(
      0,
      (total, room) => total + room.price,
    );

    return SafeArea(
      bottom: false,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'assets/RUMA LOGO 1.png',
                    height: 24,
                    color: AppTheme.accent,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'RUMA',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Profile Owner',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                OwnerPanel(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      OwnerProfileAvatar(
                        imageData: user?.profileImage ?? '',
                        size: 70,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name
                                  : 'Owner',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email.isNotEmpty == true
                                  ? user!.email
                                  : '${houses.length} kos dikelola',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        title: 'Kamar',
                        value: '${rooms.length}',
                        icon: Icons.meeting_room,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileMetric(
                        title: 'Penghuni',
                        value: '${tenants.length}',
                        icon: Icons.people,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        title: 'Kosong',
                        value: '$availableRooms',
                        icon: Icons.event_available,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileMetric(
                        title: 'Bulanan',
                        value: _money(monthlyRevenue),
                        icon: Icons.account_balance_wallet,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OwnerSectionTitle(title: 'Akun dan Pengaturan'),
                const SizedBox(height: 10),
                OwnerPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ProfileAction(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Data Owner',
                        subtitle: user == null
                            ? 'Memuat data user login'
                            : [
                                if (user.phone.isNotEmpty) user.phone,
                                if (user.birthDate.isNotEmpty) user.birthDate,
                              ].isEmpty
                            ? '${user.role} - ID ${user.id}'
                            : [
                                if (user.phone.isNotEmpty) user.phone,
                                if (user.birthDate.isNotEmpty) user.birthDate,
                              ].join(' - '),
                        onTap: _openEditProfile,
                      ),
                      const Divider(height: 1),
                      _ProfileAction(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifikasi',
                        subtitle: 'Pantau keluhan dan pembayaran',
                      ),
                      const Divider(height: 1),
                      _ProfileAction(
                        icon: Icons.lock_outline,
                        title: 'Keamanan',
                        subtitle: 'Ganti password dibuat di menu terpisah',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB23A48),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.title,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OwnerPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.darkOlive, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: compact ? 14 : 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user, required this.auth});

  final UserProfile user;
  final AuthProvider auth;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _addressController;
  late String _selectedGender;
  late String _profileImage;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _birthDateController = TextEditingController(text: widget.user.birthDate);
    _addressController = TextEditingController(text: widget.user.address);
    _selectedGender = widget.user.gender.isNotEmpty
        ? widget.user.gender
        : 'Laki-laki';
    _profileImage = widget.user.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<bool> _saveProfile({required bool closeOnSuccess}) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama owner harus diisi.')));
      return false;
    }

    setState(() => _isSaving = true);
    final updated = await widget.auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      birthDate: _birthDateController.text.trim(),
      address: _addressController.text.trim(),
      profileImage: _profileImage,
    );
    if (!mounted) return updated;

    setState(() => _isSaving = false);
    if (updated && closeOnSuccess) {
      Navigator.pop(context, updated);
    } else if (!updated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile gagal disimpan.')));
    }
    return updated;
  }

  Future<void> _save() async {
    await _saveProfile(closeOnSuccess: true);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final currentValue = DateTime.tryParse(_birthDateController.text);
    final initialDate = currentValue != null && !currentValue.isAfter(now)
        ? currentValue
        : DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked == null || !mounted) return;
    setState(() {
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _pickProfileImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 82,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;

      setState(() {
        _profileImage = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });

      setState(() => _isUploadingPhoto = true);
      final saved = await _saveProfile(closeOnSuccess: false);
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profile berhasil disimpan.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih gambar profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.lightBeige,
          borderRadius: BorderRadius.circular(18),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Profile Owner',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Column(
                  children: [
                    OwnerProfileAvatar(imageData: _profileImage, size: 86),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _isSaving || _isUploadingPhoto
                          ? null
                          : _pickProfileImage,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        _isUploadingPhoto ? 'Menyimpan...' : 'Upload Foto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: AppTheme.darkOlive),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Login',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _EditField(label: 'Nama Owner', controller: _nameController),
              _EditField(
                label: 'Nomor Handphone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              _GenderField(
                value: _selectedGender,
                onChanged: (value) {
                  if (value != null) {
                    _selectedGender = value;
                  }
                },
              ),
              _DateEditField(
                label: 'Tanggal Lahir',
                controller: _birthDateController,
                hintText: 'YYYY-MM-DD',
                onTap: _pickBirthDate,
              ),
              _EditField(
                label: 'Alamat',
                controller: _addressController,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}

class _DateEditField extends StatelessWidget {
  const _DateEditField({
    required this.label,
    required this.controller,
    required this.onTap,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderField extends StatefulWidget {
  const _GenderField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  State<_GenderField> createState() => _GenderFieldState();
}

class _GenderFieldState extends State<_GenderField> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jenis Kelamin',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _value,
            items: const [
              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _value = value);
              widget.onChanged(value);
            },
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
