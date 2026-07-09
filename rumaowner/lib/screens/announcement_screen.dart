import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/announcement.dart';
import '../providers/announcement_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/tenant_provider.dart';
import '../widgets/owner_widgets.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _selectedDate;
  bool _showForm = false;
  bool _isSaving = false;
  String _activeTab = 'info'; // 'info' or 'notif'
  String _targetType = 'boarding_house';
  int? _selectedTargetUserId;
  int? _loadedTenantUsersForBoardingHouseId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final bhId = context
          .read<BoardingHouseProvider>()
          .selectedBoardingHouse
          ?.id;
      context.read<AnnouncementProvider>().fetchAnnouncements(
        boardingHouseId: bhId,
      );
      context.read<PaymentProvider>().fetchPayments(boardingHouseId: bhId);
      context.read<TenantProvider>().fetchTenantUsers(boardingHouseId: bhId);
      _loadedTenantUsersForBoardingHouseId = bhId;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.darkOlive,
              onPrimary: Colors.white,
              surface: AppTheme.lightBeige,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi pengumuman wajib diisi')),
      );
      return;
    }
    final selectedBh = context
        .read<BoardingHouseProvider>()
        .selectedBoardingHouse;
    if (selectedBh == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kos dulu sebelum membuat pengumuman'),
        ),
      );
      return;
    }

    if (_targetType == 'user' && _selectedTargetUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih penghuni tujuan pengumuman')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final announcement = Announcement(
      id: 0,
      ownerId: 0,
      boardingHouseId: selectedBh.id,
      targetType: _targetType,
      targetUserId: _targetType == 'user' ? _selectedTargetUserId : null,
      title: title,
      content: content,
      date: _selectedDate ?? DateTime.now(),
      icon: 'info',
      createdAt: DateTime.now(),
    );

    final success = await context.read<AnnouncementProvider>().addAnnouncement(
      announcement,
      boardingHouseId: selectedBh.id,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedDate = null;
        _targetType = 'boarding_house';
        _selectedTargetUserId = null;
        _showForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil dikirim')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim pengumuman')),
      );
    }
  }

  Future<void> _deleteAnnouncement(Announcement item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengumuman?'),
        content: Text('Hapus "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final bhId = context
        .read<BoardingHouseProvider>()
        .selectedBoardingHouse
        ?.id;
    final success = await context
        .read<AnnouncementProvider>()
        .deleteAnnouncement(item.id, boardingHouseId: bhId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Pengumuman berhasil dihapus'
              : 'Gagal menghapus pengumuman',
        ),
      ),
    );
  }

  IconData _iconForType(String icon) {
    switch (icon) {
      case 'water':
        return Icons.water_drop_outlined;
      case 'electric':
        return Icons.flash_on_outlined;
      case 'repair':
        return Icons.build_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  int? _readUserId(Map<String, dynamic> user) {
    final id = user['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return int.tryParse(id?.toString() ?? '');
  }

  void _ensureTenantUsersForBoardingHouse(int? boardingHouseId) {
    if (boardingHouseId == null ||
        _loadedTenantUsersForBoardingHouseId == boardingHouseId) {
      return;
    }

    _loadedTenantUsersForBoardingHouseId = boardingHouseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TenantProvider>().fetchTenantUsers(
        boardingHouseId: boardingHouseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcementProvider = context.watch<AnnouncementProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final selectedBh = context
        .watch<BoardingHouseProvider>()
        .selectedBoardingHouse;

    // Filter paid payments to show as notifications
    final paidPayments = paymentProvider.payments
        .where((p) => p.status == 'paid')
        .toList();
    final selectedBhId = selectedBh?.id;
    _ensureTenantUsersForBoardingHouse(selectedBhId);
    final tenantUsers =
        selectedBhId != null &&
            tenantProvider.tenantUsersBoardingHouseId == selectedBhId
        ? tenantProvider.tenantUsers
        : <Map<String, dynamic>>[];

    if (_selectedTargetUserId != null &&
        !tenantUsers.any(
          (user) => _readUserId(user) == _selectedTargetUserId,
        )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedTargetUserId = null);
      });
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          final bhId = context
              .read<BoardingHouseProvider>()
              .selectedBoardingHouse
              ?.id;
          final announcementProvider = context.read<AnnouncementProvider>();
          final paymentProvider = context.read<PaymentProvider>();
          final tenantProvider = context.read<TenantProvider>();
          await announcementProvider.fetchAnnouncements(boardingHouseId: bhId);
          if (!mounted) return;
          await Future.wait([
            paymentProvider.fetchPayments(boardingHouseId: bhId),
            tenantProvider.fetchTenantUsers(boardingHouseId: bhId),
          ]);
          _loadedTenantUsersForBoardingHouseId = bhId;
        },
        color: AppTheme.darkOlive,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTab == 'info'
                              ? 'Kirim info ke semua penghuni'
                              : 'Notifikasi Masuk',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeTab == 'info'
                              ? 'Untuk ${selectedBh?.name ?? 'kos terpilih'}'
                              : 'Riwayat transaksi lunas dan aktivitas sistem',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (_activeTab == 'info')
                    GestureDetector(
                      onTap: () => setState(() => _showForm = !_showForm),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.darkOlive,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _showForm ? Icons.close : Icons.add,
                          color: AppTheme.lightBeige,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Tab Selector
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'info'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 'info'
                                  ? AppTheme.darkOlive
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Kirim Pengumuman',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _activeTab == 'info'
                                ? AppTheme.darkOlive
                                : AppTheme.textSecondary,
                            fontWeight: _activeTab == 'info'
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'notif'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 'notif'
                                  ? AppTheme.darkOlive
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Notifikasi Masuk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _activeTab == 'notif'
                                ? AppTheme.darkOlive
                                : AppTheme.textSecondary,
                            fontWeight: _activeTab == 'notif'
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_activeTab == 'info') ...[
                Text(
                  'Daftar Pengumuman Terbaru',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paling baru diurutkan paling atas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                if (announcementProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.darkOlive,
                      ),
                    ),
                  )
                else if (announcementProvider.announcements.isEmpty)
                  OwnerPanel(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Belum ada pengumuman.\nTekan + untuk membuat pengumuman baru.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  ...announcementProvider.announcements.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _AnnouncementRow(
                        item: item,
                        icon: _iconForType(item.icon),
                        onDelete: () => _deleteAnnouncement(item),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showForm
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: _buildForm(tenantUsers),
                  secondChild: GestureDetector(
                    onTap: () => setState(() => _showForm = true),
                    child: OwnerPanel(
                      backgroundColor: AppTheme.darkOlive,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: AppTheme.lightBeige),
                          const SizedBox(width: 8),
                          Text(
                            'Buat Pengumuman Baru',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.lightBeige,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Payment Notifications Tab
                Text(
                  'Aktivitas Pembayaran Tenant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Konfirmasi otomatis dari Midtrans',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                if (paymentProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.darkOlive,
                      ),
                    ),
                  )
                else if (paidPayments.isEmpty)
                  OwnerPanel(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Belum ada riwayat pembayaran lunas.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  ...paidPayments.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OwnerPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDF5E4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: Color(0xFF295433),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pembayaran Diterima',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.tenant?.userName ?? 'Tenant'} (${p.tenant?.roomNumber ?? 'Room'}) telah membayar tagihan ${p.billingPeriod} sebesar ${_formatCurrency(p.amount)}.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textDark,
                                          fontSize: 12,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.paidAt != null
                                        ? DateFormat(
                                            'd MMM yyyy, HH.mm',
                                            'id_ID',
                                          ).format(p.paidAt!)
                                        : DateFormat(
                                            'd MMM yyyy, HH.mm',
                                            'id_ID',
                                          ).format(p.paymentDate),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<Map<String, dynamic>> tenantUsers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formLabel('Judul Pengumuman'),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: _inputDecoration('Contoh: Perubahan Jadwal Layanan'),
        ),
        const SizedBox(height: 4),
        _helperText('Singkat, maksimal 60 karakter.'),
        const SizedBox(height: 16),
        _formLabel('Isi Pengumuman'),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 3,
          decoration: _inputDecoration('Tulis pengumuman di sini...'),
        ),
        const SizedBox(height: 4),
        _helperText('Gunakan poin-poin jika diperlukan.'),
        const SizedBox(height: 16),
        _formLabel('Tanggal Pengumuman'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0DDD6)),
            ),
            child: Text(
              _selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                  : 'Pilih tanggal (dd/mm/yyyy)',
              style: TextStyle(
                color: _selectedDate != null
                    ? AppTheme.textDark
                    : const Color(0xFFB0ACA1),
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _helperText('Pengumuman akan ditampilkan mulai tanggal tersebut.'),
        const SizedBox(height: 16),
        _formLabel('Target Penyebaran'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TargetOptionButton(
                label: 'Kos',
                icon: Icons.home_work_outlined,
                selected: _targetType == 'boarding_house',
                onTap: () => setState(() {
                  _targetType = 'boarding_house';
                  _selectedTargetUserId = null;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TargetOptionButton(
                label: 'Penghuni',
                icon: Icons.person_outline,
                selected: _targetType == 'user',
                onTap: () => setState(() => _targetType = 'user'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _helperText(
          _targetType == 'boarding_house'
              ? 'Dikirim ke semua penghuni di kos aktif.'
              : 'Dikirim hanya ke penghuni yang dipilih.',
        ),
        if (_targetType == 'user') ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue:
                tenantUsers.any(
                  (user) => _readUserId(user) == _selectedTargetUserId,
                )
                ? _selectedTargetUserId
                : null,
            isExpanded: true,
            decoration: _inputDecoration('Pilih penghuni'),
            items: tenantUsers
                .map((user) {
                  final id = _readUserId(user);
                  if (id == null) return null;
                  final name = user['name']?.toString() ?? 'Penghuni';
                  final email = user['email']?.toString() ?? '';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      email.isEmpty ? name : '$name - $email',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                })
                .whereType<DropdownMenuItem<int>>()
                .toList(),
            onChanged: (value) => setState(() => _selectedTargetUserId = value),
          ),
          const SizedBox(height: 4),
          _helperText(
            tenantUsers.isEmpty
                ? 'Belum ada penghuni di kos ini.'
                : 'Daftar ini mengikuti kos yang sedang aktif.',
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _titleController.clear();
                  _contentController.clear();
                  setState(() {
                    _selectedDate = null;
                    _targetType = 'boarding_house';
                    _selectedTargetUserId = null;
                    _showForm = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.darkOlive),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.darkOlive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkOlive,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Pengumuman',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _formLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  Widget _helperText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.textSecondary,
        fontSize: 12,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0ACA1)),
      filled: true,
      fillColor: AppTheme.cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0DDD6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0DDD6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.darkOlive, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow({
    required this.item,
    required this.icon,
    required this.onDelete,
  });

  final Announcement item;
  final IconData icon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, HH.mm', 'id_ID').format(item.date);
    final isUserTarget = item.targetType == 'user';
    final targetLabel = isUserTarget
        ? 'Untuk ${item.targetUserName ?? 'penghuni tertentu'}'
        : 'Untuk semua penghuni kos';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _TargetBadge(
                      label: targetLabel,
                      icon: isUserTarget
                          ? Icons.person_outline
                          : Icons.home_work_outlined,
                    ),
                    Text(
                      '$dateLabel WIB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Color(0xFFB23A48),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetOptionButton extends StatelessWidget {
  const _TargetOptionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.darkOlive : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.darkOlive : const Color(0xFFE0DDD6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppTheme.lightBeige : AppTheme.textDark,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? AppTheme.lightBeige : AppTheme.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  const _TargetBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7DABF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
