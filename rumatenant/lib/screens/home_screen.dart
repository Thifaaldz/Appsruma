import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/complaint.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _tenantInfo;
  Map<String, dynamic>? _roomInfo;
  Map<String, dynamic>? _boardingHouseInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch tenant's own info
      final tenantRes = await _apiClient.dio.get('/tenants');
      if (tenantRes.statusCode == 200 && tenantRes.data is List && (tenantRes.data as List).isNotEmpty) {
        final tenantData = tenantRes.data[0];
        setState(() {
          _tenantInfo = tenantData;
          if (tenantData['room'] != null) {
            _roomInfo = tenantData['room'];
          }
          if (tenantData['user'] != null) {
            _tenantInfo!['user_name'] = tenantData['user']['name'];
            _tenantInfo!['user_email'] = tenantData['user']['email'];
          }
        });

        // Fetch boarding house info using room's boarding_house_id
        if (_roomInfo != null && _roomInfo!['boarding_house_id'] != null) {
          try {
            final bhRes = await _apiClient.dio.get('/boarding-houses/${_roomInfo!['boarding_house_id']}');
            if (bhRes.statusCode == 200) {
              setState(() => _boardingHouseInfo = bhRes.data);
            }
          } catch (_) {}
        }
      }

      // Also fetch complaints
      if (mounted) {
        context.read<ComplaintProvider>().fetchComplaints();
      }
    } catch (e) {
      debugPrint('Error loading tenant data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();
    final pendingComplaints = complaintProvider.complaints
        .where((c) => c.status != 'done' && c.status != 'Done')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/RUMA LOGO 1.png',
            height: 32,
            color: AppTheme.darkOlive,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'RUMA',
                style: TextStyle(
                  color: AppTheme.darkOlive,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 32),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.textDark),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Halo, ${_tenantInfo?['user_name'] ?? 'Penghuni'}!',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selamat datang di kos Anda.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Room Info Card
                    _buildSectionCard(
                      context,
                      icon: Icons.bed,
                      title: 'Info Kamar',
                      children: [
                        _buildInfoRow('Kos', _boardingHouseInfo?['name'] ?? '-'),
                        _buildInfoRow('Alamat', _boardingHouseInfo?['address'] ?? '-'),
                        _buildInfoRow('Nomor Kamar', _roomInfo?['room_number'] ?? '-'),
                        _buildInfoRow('Status', _roomInfo?['status'] ?? '-'),
                        _buildInfoRow(
                          'Harga',
                          _roomInfo?['price'] != null
                              ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                                  .format(_roomInfo!['price'])
                              : '-',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tenant Info Card
                    _buildSectionCard(
                      context,
                      icon: Icons.person,
                      title: 'Profil Saya',
                      children: [
                        _buildInfoRow('Nama', _tenantInfo?['user_name'] ?? '-'),
                        _buildInfoRow('Email', _tenantInfo?['user_email'] ?? '-'),
                        _buildInfoRow('No. HP', _tenantInfo?['phone'] ?? '-'),
                        _buildInfoRow('Jenis Kelamin', _tenantInfo?['gender'] ?? '-'),
                        _buildInfoRow(
                          'Check-in',
                          _tenantInfo?['check_in_date'] != null
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(_tenantInfo!['check_in_date']))
                              : '-',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.report_problem,
                            label: 'Keluhan Aktif',
                            value: '$pendingComplaints',
                            color: pendingComplaints > 0 ? AppTheme.statusRedBg : AppTheme.statusGreenBg,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.check_circle,
                            label: 'Total Keluhan',
                            value: '${complaintProvider.complaints.length}',
                            color: AppTheme.statusBlueBg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkOlive,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.lightBeige, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppTheme.textDark),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
